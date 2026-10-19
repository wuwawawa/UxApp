@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cd /d "%~dp0"

rem ============================================================
rem  hdc_screenshot.bat - 一次运行连续截取多个屏幕状态
rem
rem  用法: hdc_screenshot.bat [文件名前缀] [模式] [设备SN]
rem
rem    文件名前缀  默认 screenshot
rem
rem    模式        默认 all
rem      all   F态 + M态, 每态各截 原始方向/旋转方向 2 张
rem      f     只截 F 态 折叠态
rem      m     只截 M 态 展开态
rem      none  不切屏态/不旋转, 按当前状态截 1 张 旧版行为
rem
rem    设备SN      可选, 多设备连接时用于指定目标
rem
rem  文件名形如: 前缀_状态_方向_时间戳.jpeg
rem    状态: f = F态(折叠) / m = M态(展开) / current
rem    方向: ori  = 原始方向, 对应 hidumper -a -motion,0
rem          left = 旋转方向, 对应 hidumper -a -motion,1
rem  输出目录: <工程根目录>\repro\ (已加入 .gitignore, 不会被提交)
rem
rem  示例:
rem    hdc_screenshot.bat truncation
rem    hdc_screenshot.bat truncation f
rem    hdc_screenshot.bat truncation all 7001005458323933328a1d0e3f3b3c00
rem
rem  屏态/旋转命令取自 DevEco UxCheckUtil
rem  plugins\app-analyzer\lib\hos-app-analyzer-26.0.0.851.jar
rem  messages/AppAnalyzerCommon.properties:
rem    打开折叠屏调试 : param set dms.hidumper.supportdebug true
rem    F态 折叠       : hidumper -s 4607 -a -p
rem    M态 展开       : hidumper -s 4607 -a -y
rem    原始方向       : hidumper -s 4607 -a -motion,0
rem    旋转方向       : hidumper -s 4607 -a -motion,1
rem    读取屏态信息   : hidumper -s 4607 -a -a
rem    截图           : snapshot_display -f 远端路径
rem
rem  可选环境变量:
rem    HDC_EXE      指定 hdc.exe 完整路径
rem    WAIT_ROTATE  旋转后等待秒数, 默认 2
rem    WAIT_FOLD    折叠/展开后等待秒数, 默认 3
rem    FORCE_FOLD   设为 1 时, 探测不到折叠屏也强行按模式截图
rem ============================================================

set "PREFIX=%~1"
if "%PREFIX%"=="" set "PREFIX=screenshot"
set "MODE=%~2"
if "%MODE%"=="" set "MODE=all"
set "WANT_SN=%~3"

set "REMOTE_DIR=/data/local/tmp/ux"
set "LOCAL_DIR=%~dp0..\repro\"
set "FOLD_SVC=4607"
set "TMP_OUT=%TEMP%\hdc_screenshot_out.txt"
if not exist "%LOCAL_DIR%" mkdir "%LOCAL_DIR%" >nul 2>nul

if not defined WAIT_ROTATE set "WAIT_ROTATE=2"
if not defined WAIT_FOLD   set "WAIT_FOLD=3"

set "FAILED=0"
set "SHOT_COUNT=0"
set "FOLD_OK=0"
set "PREV_SHOT="
set "LAST_SHOT="

rem ---------- 0. 定位 hdc ----------
set "HDC_CMD="
if defined HDC_EXE if exist "%HDC_EXE%" set "HDC_CMD=%HDC_EXE%"
if not defined HDC_CMD for /f "usebackq delims=" %%p in (`where hdc 2^>nul`) do if not defined HDC_CMD set "HDC_CMD=%%p"
if not defined HDC_CMD (
    echo [ERROR] 未找到 hdc, 请将 hdc 加入 PATH, 或用 HDC_EXE 指定完整路径。
    echo         例如: set HDC_EXE=D:\path\to\toolchains\hdc.exe
    exit /b 1
)

rem ---------- 1. 生成时间戳 ----------
set "TS="
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"`) do set "TS=%%i"
if not defined TS (
    echo [ERROR] 获取时间戳失败, 请确认 powershell 可用。
    exit /b 1
)

rem ---------- 2. 确定目标设备 ----------
"%HDC_CMD%" list targets > "%TMP_OUT%" 2>nul
set "DEVICE="
set "DEVC=0"
for /f "usebackq delims=" %%d in ("%TMP_OUT%") do (
    set "LN=%%d"
    if not "!LN!"=="" if /i not "!LN!"=="[Empty]" (
        set "DEVICE=!LN!"
        set /a DEVC+=1
    )
)
if defined WANT_SN (
    set "DEVICE=%WANT_SN%"
    set "DEVC=1"
)
if not defined DEVICE (
    echo [ERROR] 未检测到设备, 请连接设备后执行 "hdc list targets" 确认。
    exit /b 1
)

rem ---------- 3. 打印运行信息 ----------
echo.
echo ============================================================
echo [INFO] 时间戳    : %TS%
echo [INFO] 文件名前缀: %PREFIX%
echo [INFO] 截图模式  : %MODE%
echo [INFO] 目标设备  : %DEVICE%
echo [INFO] hdc       : %HDC_CMD%
echo ============================================================

if !DEVC! GTR 1 if not defined WANT_SN (
    echo [WARN] 检测到 !DEVC! 台设备, 默认使用最后一台: !DEVICE!
    echo [WARN] 如需指定设备, 请用第 3 个参数传入设备 SN。
    echo.
)

rem ---------- 4. 探测折叠屏并读取当前屏态 ----------
echo.
echo [INFO] 读取折叠屏状态 ...
call :show_fold_status
if "%FOLD_OK%"=="1" (
    echo [INFO] 已识别到折叠屏状态字段。
) else (
    echo [INFO] 未读到 Rotation / Fold 等折叠屏状态字段。
)

if /i "%MODE%"=="none" goto :single_mode
if "%FOLD_OK%"=="0" (
    if not "%FORCE_FOLD%"=="1" (
        echo [WARN] 未探测到折叠屏服务 %FOLD_SVC%, 无法切换 F态/M态。
        echo [WARN] 改为按当前状态只截 1 张; 若确认是折叠屏, 可先执行:
        echo          set FORCE_FOLD=1
        goto :single_mode
    )
    echo [WARN] FORCE_FOLD=1, 跳过折叠屏探测, 继续按 %MODE% 模式截图。
)

rem ---------- 5. 准备设备 ----------
call :enable_fold_debug
call :wakeup

rem ---------- 6. 按模式截取 ----------
if /i "%MODE%"=="all" (
    call :capture_state f F
    call :capture_state m M
    goto :done_states
)
if /i "%MODE%"=="f" (
    call :capture_state f F
    goto :done_states
)
if /i "%MODE%"=="m" (
    call :capture_state m M
    goto :done_states
)
echo [WARN] 未知模式 "%MODE%", 按 all 处理。
call :capture_state f F
call :capture_state m M

:done_states
call :rotate 0
echo.
echo [INFO] 屏态切换已完成, 设备已恢复为原始方向显示。
goto :finish

:single_mode
call :shot current 当前状态
goto :finish

:finish
rem ---------- 7. 清理设备端本次生成的临时文件 ----------
"%HDC_CMD%" -t %DEVICE% shell "rm -f %REMOTE_DIR%/%PREFIX%_*_%TS%.jpeg %REMOTE_DIR%/%PREFIX%_*_%TS%.png" >nul 2>nul
if exist "%TMP_OUT%" del /q "%TMP_OUT%" >nul 2>nul

echo.
if "%FAILED%"=="1" (
    echo [WARN] 本次共生成 %SHOT_COUNT% 张截图, 其中存在失败项, 请检查上面的日志。
) else (
    echo [OK] 截图完成, 共生成 %SHOT_COUNT% 张, 保存在: %LOCAL_DIR%
)
echo ============================================================

set "RC=0"
if "%FAILED%"=="1" set "RC=1"
endlocal & exit /b %RC%


rem ============================================================
rem  子过程
rem ============================================================

rem ---------- 读取折叠屏状态: hidumper -s 4607 -a -a ----------
rem  输出 Rotation / FoldStatus 等字段, 并据此判断是否折叠屏
:show_fold_status
"%HDC_CMD%" -t %DEVICE% shell "hidumper -s %FOLD_SVC% -a -a" > "%TMP_OUT%" 2>nul
set "FOLD_OK=0"
powershell -NoProfile -Command "$m = Select-String -LiteralPath '%TMP_OUT%' -Pattern '^\s*\S*(Rotation|Fold)\S*\s*:'; if ($m) { $m.Line; exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo        ^<无屏态字段^>
) else (
    set "FOLD_OK=1"
)
exit /b 0

rem ---------- 打开折叠屏调试开关 ----------
:enable_fold_debug
echo.
echo [INFO] 打开折叠屏调试开关: param set dms.hidumper.supportdebug true
"%HDC_CMD%" -t %DEVICE% shell "param set dms.hidumper.supportdebug true" >nul 2>nul
if errorlevel 1 echo [WARN] 打开调试开关失败, 若屏态切换无效请检查设备权限。
exit /b 0

rem ---------- 唤醒设备 ----------
:wakeup
echo [INFO] 唤醒设备: power-shell wakeup
"%HDC_CMD%" -t %DEVICE% shell "power-shell wakeup" >nul 2>nul
call :wait 1
exit /b 0

rem ---------- 截取某个屏态: %1=f/m, %2=F/M ----------
:capture_state
set "ST_KEY=%~1"
set "ST_LABEL=%~2"
call :rotate 0
if /i "%ST_KEY%"=="f" (
    call :fold_state F
) else (
    call :fold_state M
)
call :shot %ST_KEY%_ori %ST_LABEL%态-原始方向
call :rotate 1
call :shot %ST_KEY%_left %ST_LABEL%态-旋转方向
call :dedupe %ST_LABEL%态
exit /b 0

rem ---------- 切换屏态: %1=F/M ----------
:fold_state
if /i "%~1"=="F" (
    set "FS_ARG=-p"
    set "FS_NAME=F态 折叠"
    set "FS_EXPECT=FOLDED"
) else (
    set "FS_ARG=-y"
    set "FS_NAME=M态 展开"
    set "FS_EXPECT=EXPAND"
)
echo.
echo [INFO] 切换屏态: !FS_NAME!  hidumper -s %FOLD_SVC% -a !FS_ARG!
"%HDC_CMD%" -t %DEVICE% shell "hidumper -s %FOLD_SVC% -a !FS_ARG!" >nul 2>nul
if errorlevel 1 echo [WARN] 屏态切换命令返回非 0, 设备可能不支持该命令。
call :wait %WAIT_FOLD%
call :show_fold_status
exit /b 0

rem ---------- 旋转屏幕: %1=0 原始方向 / 1 旋转方向 ----------
:rotate
if "%~1"=="0" (
    set "ROT_ARG=0"
    set "ROT_NAME=原始方向"
) else (
    set "ROT_ARG=1"
    set "ROT_NAME=旋转方向"
)
echo.
echo [INFO] 旋转屏幕: !ROT_NAME!  hidumper -s %FOLD_SVC% -a -motion,!ROT_ARG!
"%HDC_CMD%" -t %DEVICE% shell "hidumper -s %FOLD_SVC% -a -motion,!ROT_ARG!" >nul 2>nul
if errorlevel 1 echo [WARN] 旋转命令返回非 0, 设备可能不支持 motion 控制。
call :wait %WAIT_ROTATE%
exit /b 0

rem ---------- 截图并拉取: %1=文件名标识, %2=说明 ----------
:shot
set "SHOT_TAG=%~1"
set "SHOT_DESC=%~2"
set "PREV_SHOT=!LAST_SHOT!"
set /a SHOT_COUNT+=1
set "REMOTE_FILE=%REMOTE_DIR%/%PREFIX%_%SHOT_TAG%_%TS%.jpeg"
set "LOCAL_FILE=%LOCAL_DIR%%PREFIX%_%SHOT_TAG%_%TS%.jpeg"
echo.
echo [!SHOT_COUNT!] 截图: !SHOT_DESC!
echo       设备路径: !REMOTE_FILE!
"%HDC_CMD%" -t %DEVICE% shell "mkdir -p %REMOTE_DIR%" >nul 2>nul
"%HDC_CMD%" -t %DEVICE% shell "snapshot_display -f !REMOTE_FILE!" >nul 2>nul
if errorlevel 1 (
    echo [WARN] snapshot_display 失败, 改用 uitest screenCap ...
    "%HDC_CMD%" -t %DEVICE% shell "uitest screenCap -p !REMOTE_FILE!" >nul 2>nul
)
"%HDC_CMD%" -t %DEVICE% file recv "!REMOTE_FILE!" "!LOCAL_FILE!" >nul 2>nul
if not exist "!LOCAL_FILE!" (
    echo [ERROR] 截图失败, 未生成本地文件: !LOCAL_FILE!
    set "FAILED=1"
    set "LAST_SHOT="
    exit /b 1
)
echo       [OK] 本地路径: !LOCAL_FILE!
set "LAST_SHOT=!LOCAL_FILE!"
exit /b 0

rem ---------- 旋转前后画面完全相同则删除重复张: %1=屏态说明 ----------
:dedupe
if not defined PREV_SHOT exit /b 0
if not defined LAST_SHOT exit /b 0
fc /b "!PREV_SHOT!" "!LAST_SHOT!" >nul 2>nul
if errorlevel 1 (
    set "PREV_SHOT="
    exit /b 0
)
echo.
echo [WARN] %~1 旋转前后画面完全相同, 该屏态不随旋转变化, 已删除重复截图:
echo        !LAST_SHOT!
del /q "!LAST_SHOT!" >nul 2>nul
set /a SHOT_COUNT-=1
set "PREV_SHOT="
set "LAST_SHOT="
exit /b 0

rem ---------- 等待 %1 秒 ----------
:wait
set /a "_wait_pings=%~1+1"
ping -n !_wait_pings! 127.0.0.1 >nul 2>nul
exit /b 0
