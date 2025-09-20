@echo off
setlocal enabledelayedexpansion

set ANDROID_NDK_HOME=path/to/android/ndk

:: Clean output directory
set OUTPUT_DIR=build
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

:: 1. Build Windows
echo Building Windows/amd64...
go build -o "%OUTPUT_DIR%\dragonfly_windows_amd64.exe" main.go
if %errorlevel% neq 0 goto error

:: 2. Build Linux
echo Building Linux/amd64...
set GOOS=linux
set GOARCH=amd64
go build -o "%OUTPUT_DIR%\dragonfly_linux_amd64" main.go
if %errorlevel% neq 0 goto error

:: 3. Build macOS (Intel)
echo Building macOS/amd64...
set GOOS=darwin
set GOARCH=amd64
go build -o "%OUTPUT_DIR%\dragonfly_macos_amd64" main.go
if %errorlevel% neq 0 goto error

:: 4. Build macOS (ARM)
echo Building macOS/arm64...
set GOARCH=arm64
go build -o "%OUTPUT_DIR%\dragonfly_macos_arm64" main.go
if %errorlevel% neq 0 goto error

:: 5. Build Android (optional)
echo Building Android/arm64...
if not "%ANDROID_NDK_HOME%" == "" (
    set GOOS=android
    set CGO_ENABLED=1
    set CC=%ANDROID_NDK_HOME%\toolchains\llvm\prebuilt\windows-x86_64\bin\aarch64-linux-android21-clang
    go build -o "%OUTPUT_DIR%\dragonfly_android" main.go
    if %errorlevel% neq 0 goto error
) else (
    echo ANDROID_NDK_HOME not set, skipping Android build
)

:: Success
echo.
echo Build completed successfully!
dir /b "%OUTPUT_DIR%"
pause
exit /b 0

:error
echo.
echo Build failed with error %errorlevel%
pause
exit /b %errorlevel%