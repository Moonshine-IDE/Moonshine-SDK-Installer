;NSIS Modern User Interface
;Basic Example Script
;Written by Joost Verburg

;--------------------------------
;Includes

	!include "MUI2.nsh"
	!include "FileFunc.nsh"
	!include "WinMessages.nsh"

;--------------------------------
;General

	;Name and file
	Name "${INSTALLERNAME}"
	OutFile "DEPLOY\${INSTALLERNAME}-${VERSION}.exe"

	;Default installation folder
	InstallDir "$PROGRAMFILES64\${INSTALLERNAME}"
	
	;Get installation folder from registry if available
	InstallDirRegKey HKCU "Software\${INSTALLERNAME}" ""

	;Request application privileges for Windows Vista and higher
	RequestExecutionLevel admin

;--------------------------------
;Start of running process check

!define APP_NAME find_close_terminate
!define WND_PROCESS_TITLE "Moonshine SDK Installer"
!define TO_MS 2000
!define SYNC_TERM 0x00100001

LangString termMsg 0 "An instance of ${WND_PROCESS_TITLE} is already running.$\nDo you want to terminate the instance and continue?"
LangString stopMsg 0 "Stopping ${WND_PROCESS_TITLE} Application"

!macro TerminateApp processName
 
 
    Push $0 ; window handle
    Push $1
    Push $2 ; process handle
    DetailPrint "$(stopMsg)"
	ExecCmd::exec /NOUNLOAD /ASYNC /TIMEOUT=2000 "%SystemRoot%\System32\tasklist /NH /FI $\"IMAGENAME eq ${processName}$\" | %SystemRoot%\System32\find /I $\"Moonshine$\""
    Pop $0 ; The handle for the process
    ExecCmd::wait $0
	Pop $0 ; return value
    StrCmp $0 "0" 0 doneTerminateApp
    System::Call 'user32.dll::GetWindowThreadProcessId(i r0, *i .r1) i .r2'
    System::Call 'kernel32.dll::OpenProcess(i ${SYNC_TERM}, i 0, i r1) i .r2'
    SendMessage $0 ${WM_CLOSE} 0 0 /TIMEOUT=${TO_MS}
    System::Call 'kernel32.dll::WaitForSingleObject(i r2, i ${TO_MS}) i .r1'
    IntCmp $1 0 close
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(termMsg)" /SD IDYES IDYES terminate
    System::Call 'kernel32.dll::CloseHandle(i r2) i .r1'
    Quit
  terminate:
    ExecCmd::exec "%SystemRoot%\System32\taskkill /IM $\"${processName}$\" /F"
    ExecCmd::wait $0
  close:
    System::Call 'kernel32.dll::CloseHandle(i r2) i .r1'
  doneTerminateApp:
    Pop $2
    Pop $1
    Pop $0
 
!macroend

;--------------------------------
;End of running process check
	
Function .onInit
	!insertmacro TerminateApp "${EXECUTABLENAME}.exe"
	
	ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"TimeStamp"
	StrCmp $R0 "" done
	StrCmp $R0 "${TIMESTAMP}" 0 done
	MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION \
		"A same version of Moonshine-SDK-Installer found already installed. Do you want to run the installed version?$\n$\n \
		Yes - To run the installed version.$\n \
		No - To uninstall the installed version and re-install again.$\n \
		Cancel - to cancel this installation." \
		IDYES run_application IDNO run_uninstaller
		Abort
	run_application:
		ClearErrors
		Exec "$INSTDIR\${EXECUTABLENAME}.exe"
		Abort
	run_uninstaller:
		ClearErrors
		;look for the nsis uninstaller as a special case
		ReadRegStr $R1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
			"UninstallString64bit"
		StrCmp $R1 "$\"$INSTDIR\uninstall.exe$\"" 0 +3
			ExecWait '$R1 _?=$INSTDIR'
				Goto +2
				ExecWait '$R1'
	
		IfErrors uninstall_fail uninstall_success
		uninstall_fail:
			Quit
		uninstall_success:
			Delete "$INSTDIR\uninstall.exe"
			RmDir "$INSTDIR"
	done:
FunctionEnd

;--------------------------------
;Interface Settings

	!define MUI_HEADERIMAGE
	;!define MUI_HEADERIMAGE_BITMAP "header.bmp"
	;!define MUI_WELCOMEFINISHPAGE_BITMAP "wizard.bmp"
	!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXECUTABLENAME}.exe"
	!define MUI_FINISHPAGE_RUN_TEXT "Run ${EXECUTABLENAME}"
	!define MUI_FINISHPAGE_NOAUTOCLOSE
	;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
	;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
	!define MUI_ABORTWARNING

;--------------------------------
;Pages

	!insertmacro MUI_PAGE_WELCOME
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_PAGE_FINISH
	
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES
	
;--------------------------------
;Languages
 
	!insertmacro MUI_LANGUAGE "English"
	
;--------------------------------
;Installer Sections

Section "Moonshine-SDK-Installer" SecMoonshineSDKInstaller

	;copy all files
	SetOutPath "$INSTDIR"
	File /r "DEPLOY\${INSTALLERNAME}EXE\*"
	
	;Store installation folder
	WriteRegStr HKCU "Software\${INSTALLERNAME}" "" $INSTDIR
	
	;Create uninstaller
	WriteUninstaller "$INSTDIR\uninstall.exe"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"DisplayName" "${INSTALLERNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"Publisher" "Prominic.NET, Inc."
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"URLInfoAbout" "https://moonshine-ide.com"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"DisplayVersion" "${VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"TimeStamp" "${TIMESTAMP}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"HelpLink" "https://moonshine-ide.com/faq/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"DisplayIcon" "$\"$INSTDIR\${EXECUTABLENAME}.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"UninstallString64bit" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"NoModify" 0x1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"NoRepair" 0x1
	
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"EstimatedSize" "$0"
	
	;Create Start Menu entry
	CreateShortCut "$SMPROGRAMS\${INSTALLERNAME} (64-bit).lnk" "$INSTDIR\${EXECUTABLENAME}.exe"

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

	RMDir /r "$INSTDIR\*"
	RMDir "$INSTDIR"
	
	Delete "$SMPROGRAMS\${INSTALLERNAME}.lnk"
	
	DeleteRegKey /ifempty HKCU "Software\${INSTALLERNAME}"
	
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"
SectionEnd