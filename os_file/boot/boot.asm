[org 0x7c00]             ; BIOSがMBRをロードするアドレス

start:
    ; --- 初期設定 ---
    xor ax, ax            ; デフォルトのDS, ESセグメント設定
    mov ds, ax
    mov es, ax

    ; --- 起動メッセージを表示 ---
    mov si, msg_welcome   ; "free_OS" を指す
    call print_string

    ; --- C:boot/Check_OS.bin の存在確認 ---
    mov si, file_check_os
    call check_file
    jnz file_not_found    ; ファイルが見つからなければエラー処理

    ; --- C:Open_OS の存在確認 ---
    mov si, file_open_os
    call check_file
    jnz file_not_found    ; ファイルが見つからなければエラー処理

    ; --- ファイルの実行 (C:boot/Check_OS.bin) ---
    call load_file
    jmp 0x8000            ; メモリ上にロードされたプログラムを実行

file_not_found:
    mov si, msg_not_found
    call print_string
    call wait_10_seconds  ; 10秒待機
    cli
    hlt                   ; システム終了

; --- サブルーチン群 ---
print_string:
    lodsb                 ; ALに次の文字をロード
    or al, al             ; NULLチェック
    jz print_done
    mov ah, 0x0e          ; BIOSテキスト出力
    int 0x10
    jmp print_string
print_done:
    ret

check_file:
    ; 仮のファイル存在確認（実際にはディスクアクセス処理を実装）
    ; 現段階では「常に成功した」と仮定
    xor ax, ax            ; 戻り値を0（成功）に設定
    ret

load_file:
    ; 仮のファイル読み込み処理
    ; 実際にはBIOSのディスク読み込み（INT 0x13）を用いる
    ret

wait_10_seconds:
    mov cx, 0x2A30        ; 約10秒間ループ (BIOSタイマー依存)
wait_loop:
    loop wait_loop
    ret

; --- メッセージ定義 ---
msg_welcome db "free_OS", 0
msg_not_found db "File not found.", 0
file_check_os db "C:boot/Check_OS.bin", 0
file_open_os db "C:Open_OS", 0

; --- パディングとMBRシグネチャ ---
times 510-($-$$) db 0   ; 510バイトまで埋める
dw 0xAA55               ; ブートセクタシグネチャ
