
.model small

org 100h

.code
start:  
  mov dl, " "           ; print a single white space
  mov ah, 02h           ; when the white space is not printed
  int 21h               ; the first char of the input is erased from the terminal
  
  sub sp, 255           ; allocate 255 byte space for the input
  mov bx, sp            ; move the addr of the allocated space
  mov ax, 252           ; max size of the input
  mov [bx], ax
  
  mov dx, bx
  mov ah, 0ah
  int 21h               ; read buffered input
  
  mov bx, sp            ; addr of expr
  add bx, 1             ; bx points to the size of the input
  mov cl, [bx]          ; cl = size of the input
  mov ch, 0
  mov si, cx            ; si = size
  add bx, 1             ; bx points to the beginning of the expr
  mov al, "$"           ; terminating char
  mov [bx si], al       ; put $ at the end
  
  mov dx, offset cr     ; print carriage return
  mov ah, 09h
  int 21h
  
  mov si, 0             ; index
  mov ax, 0             ; value
  mov cx, 16            ; base
  
get_expr:
  mov dx, [bx si]       ; dl = expr[index]
  cmp dl, "$"
  je jump_final         ; end of the expr
  
  cmp dl, " "           ; space
  jne check_char
  push bx               ; store bx in stack
  mov bx, offset num_found
  mov bx, [bx]
  cmp bl, 1             ; if a num is found, get the token
  pop bx                ; load bx
  je get_token
  inc si
  jmp get_expr          ; otherwise, go to the next char
  
check_char:
  cmp dl, "0"           ; if a char is less than "0" or
  jl operator_found     ; greater than "F", then it must
  cmp dl, "F"           ; be an operator
  jg operator_found     ; otherwise it is a digit of a number
  
number_found:
  push bx
  push dx               ; store bx and dx in stack
  mov bx, offset num_found
  mov dx, 1
  mov [bx], dx          ; load true to num_found
  pop dx
  pop bx                ; load dx and bx back
  
  mov dh, 0             ; reset dh
  cmp dl, "A"
  jl numerical
  
  sub dl, "A"           ; "A" <= dl <= "F"
  add dl, 10            ; dl = digit
  jmp update_curr_value
  
numerical:              ; "0" <= dl <= "9"
  sub dl, "0"           ; dl = digit
  
update_curr_value:
  push dx               ; store dx
  mul cx                ; dx:ax = ax*cx
  pop dx                ; load dx
  add ax, dx            ; value = base*value + digit
  inc si                ; index++
  jmp get_expr
  
get_token:
  push ax               ; store value in stack
  mov ax, 0             ; reset ax
  
  push bx
  mov bx, offset num_found
  mov dx, 0             ; false
  mov [bx], dx          ; move false to num_found
  pop bx                ; restore bx
  
  inc si                ; index++
  jmp get_expr
  
jump_final:             ; this intermidiate jump is used to 
  jmp final             ; prevent "Jump > 128" Error
  
operator_found:         ; either of "+-*/^&|" is found
  push ax
  push bx               ; store ax and bx
  add sp, 6             ; jump bx, ax, num2
  pop ax                ; ax = num1
  sub sp, 4
  pop bx                ; bx = num2
  
add_operation:
  cmp dl, "+"
  jne sub_operation
  add ax, bx            ; ax = num1+num2
  jmp operator_end    
  
sub_operation:
  cmp dl, "-"
  jne mul_operation
  sub ax, bx            ; ax = num1-num2
  jmp operator_end 
  
mul_operation:
  cmp dl, "*"
  jne div_operation
  mul bx                ; dx:ax = num1*num2
  jmp operator_end    
  
div_operation:
  cmp dl, "/"
  jne eor_operation  
  mov dx, 0             ; reset dx
  div bx                ; dx=remainder, ax=quotient
  jmp operator_end       
  
eor_operation:
  cmp dl, "^"
  jne and_operation
  xor ax, bx            ; ax = num1^num2
  jmp operator_end       
  
and_operation:
  cmp dl, "&"
  jne or_operation
  and ax, bx            ; ax = num1&num2
  jmp operator_end           
  
or_operation:
  or ax, bx             ; ax = num1|num2   
  
operator_end:
  add sp, 2
  push ax
  sub sp, 6
  pop bx
  pop ax
  add sp, 2
  inc si                ; index++
  jmp get_expr                   
  
final:
  mov bx, offset num_found
  mov cx, [bx]
  cmp cl, 1
  je print_and_exit
  
  pop ax                ; pop the result to ax
  
print_and_exit:
  mov bx, offset buffer
  call print_result
  
  add sp, 255           ; restore sp
  mov ah, 4ch
  mov al, 0
  int 21h               ; exit 0
  
  
print_result proc       ; ax is a number
  push si               ; bx is the addr of the buffer of 5 bytes 
  push cx               ; store si, cx, dx
  push dx
  
  mov si, 4             ; index = 4
  mov cx, "$"           ; terminating char
  mov [bx si], cx       ; put $ at the end of the buffer
  dec si                ; index--
  mov cx, 16            ; base = 16
  mov dx, 0             ; reset dx
  
convert_to_hex:
  cmp ax, 0             ; if the number is 0 then the conversion is done
  je fill_rest
  div cx                ; ax=quotient, dx=remainder
  cmp dl, 10
  jl number
  
  sub dl, 10            ; A,B,C,D,E,F cases
  add dl, "A"
  jmp put_buffer
  
number:
  add dl, "0"           ; 0,1,2,3,4,5,6,7,8,9 cases
  
put_buffer:
  mov [bx si], dl       ; put the digit to buffer[index]
  dec si                ; index--
  mov dx, 0             ; reset dx
  jmp convert_to_hex
  
fill_rest:
  cmp si, -1            ; if index==-1 (FFFF), jump to print
  je print
  mov dl, "0"           ; else fill the rest of the buffer with "0"
  mov [bx si], dl
  dec si                ; index--
  jmp fill_rest
  
print:
  mov dx, bx
  mov ah, 09h
  int 21h
  
end_print_result:
  pop dx                ; restore dx, cx, si
  pop cx
  pop si
  ret
print_result endp
 
 
; DATA

num_found       db 0            ; true if a number is found
buffer          db "     "      ; 5 bytes
cr              dw 13,10,"$"    ; carriage return, line feed
  
  