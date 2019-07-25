
include emu8086.inc
   
;=== Principal ===  
org 100h 
gotoxy 13,13
putc 219    ; go to the center of the screen and start  

game:
    mov si, offset position
    call display_food
    call move 
    call display_snake
    mov al,[si]
    cmp af,al
    je second
    jmp else
    second:
    mov al,[si+1]
    cmp bf,al
    je creation
    jmp else
    creation:   ;the snake eat food
        call new_last
        call new_random 
    else:  
    ;call clear_screen
    cmp length,10
jne game  ; we continue the game
call clear_screen ;the game is done
gotoxy 0,0
printn 'your snake s length is 10... You won!'
ret 
lasta db ? ;lasta and lastb save the coordinates of the last element of the snake before changing
lastb db ? ;needed for the new_last procedure
length db 1 ;save the snakes's length (number of elements)
af db 7 ; af and bf are food's coordinates
bf db 15 
random db 7,15,8,6,15,13,20,14,6,23,2,15,17,19,6,21,14,22,14,5 ;an array of 10 random food coordinates 
position db 13,13, 18 dup(0);the array that will save the snake elements' coordinates

                    
define_clear_screen   

;==== PROCEDURES ====
display_food proc
    gotoxy af,bf 
    putc 3   
    ret
display_food endp 

move proc  
    update:     
        mov al, length
        dec al         ; al = length-1   
        mov dl,2
        mul dl         ; ax = 2*(length-1)
        mov cx,ax      ; cx now points at the last coordinates 
        add si,cx
        mov al,[si]
        mov lasta, al
        mov al,[si+1]
        mov lastb, al  ; save the last coordinates before changing them
        cmp cx,0      
        je key       ;taille == 1 nothing to do
        shift: 
            mov al,[si-1]
            mov [si+1],al 
            dec si   
        loop shift     ;shift all elements down once
    
    key:             ;choose direction
        gotoxy 0,0
        mov ah,01h
        int 21h                       
        cmp al, 'z'
            je up
        
        cmp al, 'q'
        je left
        
        cmp al,'s'
        je right
        
        cmp al,'w'
        je down
        
        printn 'wrong key down'
    jmp key
    
    up:
        dec [si+1] 
        jmp done
        
    left:
        dec [si]
        jmp done
        
    right:
        inc [si]
        jmp done
        
    down:
        inc [si+1]
        jmp done
    
    done:     ;updated the first element coordinates
    ret        
move endp   
         
display_snake proc
    mov cl,length  ;we continue to display until we hit length times
    mov ch,0
    display:
        gotoxy [si],[si+1]
        putc 219 
        add si,2
    loop display 
    gotoxy lasta , lastb
        putc 0  
    mov si, offset position             
    ret 
display_snake endp         
         
new_last proc  
    mov al, length         
    mov dl,2  
    mul dl         ; ax = 2*length
    mov bx,ax      ; bx = ax     
    mov al,lasta
    mov [si+bx],al ;after the last existant element
    mov al,lastb
    mov [si+bx+1],al
    inc length 
    mov si, offset position
    ret
new_last endp

new_random proc           
    mov di, offset random ;tabrandom te3 sa7
    mov al, length
    dec al          ; al = length-1   
    mov dl,2  
    mul dl          ; ax = 2*(length-1)
    mov bx,ax 
    mov dl,[di+bx]  ;dx has the new food coordinates
    mov dh,[di+bx+1];dl=af and dh=bf
    mov cl, length 
    mov ch,0
    et2:
        cmp dl,[si] ;if af=[si] and bf=[si+1] then jmp equal else jmp diff
        je secondcond 
        jmp diff
        secondcond:
        cmp dh,[si+1]
        je equal
        diff:
        add si,2
    loop et2    
    jmp done1       ;all elements are checked we're done 
    equal:          ;we found that coordinates are equal at some point
        shr dx,1    ;we shift the food coordinates to have new ones and check all over again
        mov cl,length
        jmp et2     ;make sure the new food coordinates are not equal to any element coordinates                
    done1:
        mov af,dl   ;we have the new food coordinates
        mov bf,dh        
        mov si, offset position
    ret 
new_random endp

end



