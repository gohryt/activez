.global syscall_mmap;
.type   syscall_mmap, @function;
syscall_mmap:
    movq    $9,   %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_munmap;
.type   syscall_munmap, @function;
syscall_munmap:
    movq    $11,  %rax
    syscall
    ret

.global syscall_openat;
.type   syscall_openat, @function;
syscall_openat:
    movq    $257, %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_close;
.type   syscall_close, @function;
syscall_close:
    movq    $3, %rax
    syscall
    ret

.global syscall_statx;
.type   syscall_statx, @function;
syscall_statx:
    movq    $332, %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_read;
.type   syscall_read, @function;
syscall_read:
    movq    $0, %rax
    syscall
    ret

.global syscall_write;
.type   syscall_write, @function;
syscall_write:
    movq    $1, %rax
    syscall
    ret

.global syscall_socket;
.type   syscall_socket, @function;
syscall_socket:
    movq    $41, %rax
    syscall
    ret

.global syscall_bind;
.type   syscall_bind, @function;
syscall_bind:
    movq    $49, %rax
    syscall
    ret

.global syscall_listen;
.type   syscall_listen, @function;
syscall_listen:
    movq    $50, %rax
    syscall
    ret

.global syscall_accept4;
.type   syscall_accept4, @function;
syscall_accept4:
    movq    $288, %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_recvfrom;
.type   syscall_recvfrom, @function;
syscall_recvfrom:
    movq    $45,  %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_sendto;
.type   syscall_sendto, @function;
syscall_sendto:
    movq    $44,  %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_ring_setup;
.type   syscall_ring_setup, @function;
syscall_ring_setup:
    movq    $425, %rax
    syscall
    ret

.global syscall_ring_enter;
.type   syscall_ring_enter, @function;
syscall_ring_enter:
    movq    $426, %rax
    movq    %rcx, %r10
    syscall
    ret

.global syscall_fcntl;
.type   syscall_fcntl, @function;
syscall_fcntl:
    movq    $72,  %rax
    syscall
    ret
