.586
.model flat,stdcall


include windows.inc
include kernel32.inc
include user32.inc


includelib kernel32.lib
includelib user32.lib


.data
		szReg				db 	'LovEboom[DFCG][FCG][CUG]',0
		szcap				db 	'Loader by Loveboom[DFCG][FCG][CUG]',0
		szerr				db	'Could not found :'
							db 100h dup (0)
							
		RegAddr				dd 	43F0B0h
		;RegAddr1			dd      423C06h		;showswr end 14h,14h,14h
		RegAddr1			dd	433F66h		;1dh,
		RegAddr2			dd	43A73Bh		
		PatchAddr1			dd 	006930FDh
		PatchAddr2			dd	7db870h
		raddr				dd 	00412c1eh
		pdat				db 	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
							
		pdat1				db	01dh
		pdat2				dd 	01eh
							
		rbuffer				dd 	100h dup(0)
		
		szapppath			db	100h dup(0)
		appname				db  	'4Finance.exe',0
		
		apialloc			db     69h,00h,53h,00h
						

.data?
		align				dword
		startinfo 			STARTUPINFO <> 
		pi 					PROCESS_INFORMATION <> 
		handle				dd ?
		
.code 
	start:
			;获取程序所在的路径
			invoke GetCurrentDirectory,100h,addr szapppath
			lea ebx,[eax+offset szapppath]
			cmp byte ptr [ebx-1],'\'
			je @F
			mov byte ptr [ebx],'\'
		@@:
			invoke lstrcat,addr szapppath,addr appname			
			invoke GetStartupInfo,addr startinfo
			invoke CreateProcess,addr szapppath,NULL,NULL,NULL,NULL,CREATE_SUSPENDED,NULL,NULL,addr startinfo,addr pi
			.if eax==0
				invoke lstrcat,addr szerr,addr szapppath
				invoke MessageBox,NULL,addr szerr,addr szcap,MB_OK OR MB_ICONSTOP
				jmp @@end
			.endif
			mov handle,eax
			mov ebx,offset apialloc
			;mov ebx,[ebx+2]
			mov ebx,[ebx]
		@@:
			invoke ResumeThread,pi.hThread
			invoke Sleep,1000h
			invoke SuspendThread,pi.hThread
			invoke ReadProcessMemory,pi.hProcess,raddr,addr rbuffer,4,NULL
			;mov edx,[rbuffer]
			;cmp ebx,edx
			;jne @B
			
		;如果解压完毕则添加相关信息
			invoke WriteProcessMemory,pi.hProcess,RegAddr,addr pdat,8,NULL		;写入注册名
		;	invoke WriteProcessMemory,pi.hProcess,RegAddr1,addr pdat1,1,NULL		;写入注册名
		;	invoke WriteProcessMemory,pi.hProcess,RegAddr2,addr pdat2,1,NULL		;写入注册名
		;	invoke WriteProcessMemory,pi.hProcess,PatchAddr2,addr pdat,24,NULL		;写入patch代码
		;	invoke WriteProcessMemory,pi.hProcess,PatchAddr1,addr pdat1,5,NULL		;修改原流程
			invoke ResumeThread,pi.hThread
			invoke CloseHandle,handle
		@@end:
			invoke ExitProcess,NULL
			
	end start