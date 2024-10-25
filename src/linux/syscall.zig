const std = @import("std");

pub const Error = enum(usize) {
    E2BIG = 0x7,
    EACCES = 0xd,
    EADDRINUSE = 0x62,
    EADDRNOTAVAIL = 0x63,
    EADV = 0x44,
    EAFNOSUPPORT = 0x61,
    EAGAIN = 0xb,
    EALREADY = 0x72,
    EBADE = 0x34,
    EBADF = 0x9,
    EBADFD = 0x4d,
    EBADMSG = 0x4a,
    EBADR = 0x35,
    EBADRQC = 0x38,
    EBADSLT = 0x39,
    EBFONT = 0x3b,
    EBUSY = 0x10,
    ECANCELED = 0x7d,
    ECHILD = 0xa,
    ECHRNG = 0x2c,
    ECOMM = 0x46,
    ECONNABORTED = 0x67,
    ECONNREFUSED = 0x6f,
    ECONNRESET = 0x68,
    EDEADLK = 0x23,
    EDEADLOCK = 0x23,
    EDESTADDRREQ = 0x59,
    EDOM = 0x21,
    EDOTDOT = 0x49,
    EDQUOT = 0x7a,
    EEXIST = 0x11,
    EFAULT = 0xe,
    EFBIG = 0x1b,
    EHOSTDOWN = 0x70,
    EHOSTUNREACH = 0x71,
    EIDRM = 0x2b,
    EILSEQ = 0x54,
    EINPROGRESS = 0x73,
    EINTR = 0x4,
    EINVAL = 0x16,
    EIO = 0x5,
    EISCONN = 0x6a,
    EISDIR = 0x15,
    EISNAM = 0x78,
    EKEYEXPIRED = 0x7f,
    EKEYREJECTED = 0x81,
    EKEYREVOKED = 0x80,
    EL2HLT = 0x33,
    EL2NSYNC = 0x2d,
    EL3HLT = 0x2e,
    EL3RST = 0x2f,
    ELIBACC = 0x4f,
    ELIBBAD = 0x50,
    ELIBEXEC = 0x53,
    ELIBMAX = 0x52,
    ELIBSCN = 0x51,
    ELNRNG = 0x30,
    ELOOP = 0x28,
    EMEDIUMTYPE = 0x7c,
    EMFILE = 0x18,
    EMLINK = 0x1f,
    EMSGSIZE = 0x5a,
    EMULTIHOP = 0x48,
    ENAMETOOLONG = 0x24,
    ENAVAIL = 0x77,
    ENETDOWN = 0x64,
    ENETRESET = 0x66,
    ENETUNREACH = 0x65,
    ENFILE = 0x17,
    ENOANO = 0x37,
    ENOBUFS = 0x69,
    ENOCSI = 0x32,
    ENODATA = 0x3d,
    ENODEV = 0x13,
    ENOENT = 0x2,
    ENOEXEC = 0x8,
    ENOKEY = 0x7e,
    ENOLCK = 0x25,
    ENOLINK = 0x43,
    ENOMEDIUM = 0x7b,
    ENOMEM = 0xc,
    ENOMSG = 0x2a,
    ENONET = 0x40,
    ENOPKG = 0x41,
    ENOPROTOOPT = 0x5c,
    ENOSPC = 0x1c,
    ENOSR = 0x3f,
    ENOSTR = 0x3c,
    ENOSYS = 0x26,
    ENOTBLK = 0xf,
    ENOTCONN = 0x6b,
    ENOTDIR = 0x14,
    ENOTEMPTY = 0x27,
    ENOTNAM = 0x76,
    ENOTRECOVERABLE = 0x83,
    ENOTSOCK = 0x58,
    ENOTSUP = 0x5f,
    ENOTTY = 0x19,
    ENOTUNIQ = 0x4c,
    ENXIO = 0x6,
    EOPNOTSUPP = 0x5f,
    EOVERFLOW = 0x4b,
    EOWNERDEAD = 0x82,
    EPERM = 0x1,
    EPFNOSUPPORT = 0x60,
    EPIPE = 0x20,
    EPROTO = 0x47,
    EPROTONOSUPPORT = 0x5d,
    EPROTOTYPE = 0x5b,
    ERANGE = 0x22,
    EREMCHG = 0x4e,
    EREMOTE = 0x42,
    EREMOTEIO = 0x79,
    ERESTART = 0x55,
    ERFKILL = 0x84,
    EROFS = 0x1e,
    ESHUTDOWN = 0x6c,
    ESOCKTNOSUPPORT = 0x5e,
    ESPIPE = 0x1d,
    ESRCH = 0x3,
    ESRMNT = 0x45,
    ESTALE = 0x74,
    ESTRPIPE = 0x56,
    ETIME = 0x3e,
    ETIMEDOUT = 0x6e,
    ETOOMANYREFS = 0x6d,
    ETXTBSY = 0x1a,
    EUCLEAN = 0x75,
    EUNATCH = 0x31,
    EUSERS = 0x57,
    EWOULDBLOCK = 0xb,
    EXDEV = 0x12,
    EXFULL = 0x36,
};

pub const at_FD_CWD: i32 = -100;

pub const at_symlink_nofollow: u32 = 0x100; // Can be used with statx
pub const at_removedir: u32 = 0x200; // Can be used with openat

pub const at_symlink_follow: u32 = 0x400; // Can be used with statx

pub const at_no_automount: u32 = 0x800; // Can be used with statx

pub const at_empty_path: u32 = 0x1000; // Can be used with openat
pub const at_statx_sync_type: u32 = 0x6000; // Can be used with statx
pub const at_statx_sync_as_stat: u32 = 0x0000; // Can be used with statx
pub const at_statx_force_sync: u32 = 0x2000; // Can be used with statx
pub const at_statx_dont_sync: u32 = 0x4000; // Can be used with statx
pub const at_recursive: u32 = 0x8000; // Can be used with openat

pub const Mmap = struct {
    pub const Type = enum(u4) {
        shared = 0x01,
        private = 0x02,
        shared_validate = 0x03,
    };

    pub const Flags = packed struct(u32) {
        type: Type,
        fixed: bool = false,
        anonymous: bool = false,
        @"32bit": bool = false,
        _7: u1 = 0,
        growsdown: bool = false,
        _9: u2 = 0,
        deny_write: bool = false,
        executable: bool = false,
        locked: bool = false,
        no_reserve: bool = false,
        populate: bool = false,
        nonblock: bool = false,
        stack: bool = false,
        hugetlb: bool = false,
        sync: bool = false,
        fixed_noreplace: bool = false,
        _21: u5 = 0,
        uninitialized: bool = false,
        _: u5 = 0,
    };

    pub const failed: usize = @import("std").math.maxInt(usize);
};

pub inline fn mmap(address: ?[*]u8, length: usize, prot: usize, flags: Mmap.Flags, fd: i32, offset: i64) !usize {
    const result: usize = syscall_mmap(address, length, prot, flags, fd, offset);
    if (result == Mmap.failed) {
        return result;
    }

    return result;
}

pub inline fn munmap(ptr: [*]const u8, len: usize) !void {
    const result: isize = syscall_munmap(ptr, len);
    _ = result;
}

pub const Openat = struct {
    pub const AccessMode = enum(u2) {
        r = 0,
        w = 1,
        rw = 2,
    };

    pub const Flags = packed struct(u32) {
        access_mode: AccessMode = .r,
        _2: u4 = 0,
        create: bool = false,
        exclusive: bool = false,
        no_controlling_tty: bool = false,
        truncate: bool = false,
        append: bool = false,
        nonblock: bool = false,
        dsynchronous: bool = false,
        asynchronous: bool = false,
        direct: bool = false,
        _15: u1 = 0,
        directory: bool = false,
        no_follow: bool = false,
        no_atime: bool = false,
        close_on_exec: bool = false,
        sync: bool = false,
        path: bool = false,
        tmp_file: bool = false,
        _: u9 = 0,
    };

    pub const Mode = usize;
};

pub inline fn open(directory_FD: i32, path: [*:0]const u8, flags: Openat.Flags, mode: Openat.Mode) !i32 {
    const result: i32 = syscall_openat(directory_FD, path, flags, mode);
    if (result < 0) {
        return result;
    }

    return result;
}

pub inline fn close(FD: i32) !void {
    const result: isize = syscall_close(FD);
    _ = result;
}

pub inline fn read(FD: i32, buffer: []u8) !i32 {
    const result: i32 = syscall_read(FD, buffer.ptr, buffer.len);
    if (result < 0) {
        return result;
    }
    return result;
}

pub inline fn write(FD: i32, buffer: []u8) !i32 {
    const result: i32 = syscall_write(FD, buffer.ptr, buffer.len);
    if (result < 0) {
        return result;
    }
    return result;
}

pub const Statx: type = extern struct {
    mask: u32,
    blksize: u32,
    attributes: u64,
    nlink: u32,
    uid: UID,
    gid: GID,
    mode: u16,
    reserved_1: [1]u16,
    ino: u64,
    size: u64,
    blocks: u64,
    attributes_mask: u64,
    atime: Timestamp,
    btime: Timestamp,
    ctime: Timestamp,
    mtime: Timestamp,
    rdev_major: u32,
    rdev_minor: u32,
    dev_major: u32,
    dev_minor: u32,
    reserved_2: [14]u64,

    pub const Timestamp: type = extern struct {
        second: i64,
        nanosecond: u32,
        reserved_1: u32,
    };

    pub const Mask: type = packed struct(u32) {
        type: bool = false,
        mode: bool = false,
        nlink: bool = false,
        UID: bool = false,
        GID: bool = false,
        atime: bool = false,
        mtime: bool = false,
        ctime: bool = false,
        ino: bool = false,
        size: bool = false,
        blocks: bool = false,
        btime: bool = false,
        mount_ID: bool = false,
        dioalign: bool = false,
        mount_ID_unique: bool = false,
        subvolume: bool = false,
        reserved_1: u16 = 0,

        pub const basic_stats: Mask = .{
            .type = true,
            .mode = true,
            .nlink = true,
            .UID = true,
            .GID = true,
            .atime = true,
            .mtime = true,
            .ctime = true,
            .ino = true,
            .size = true,
            .blocks = true,
        };

        pub const all: Mask = .{
            .type = true,
            .mode = true,
            .nlink = true,
            .UID = true,
            .GID = true,
            .atime = true,
            .mtime = true,
            .ctime = true,
            .ino = true,
            .size = true,
            .blocks = true,
            .btime = true,
        };
    };

    pub const UID: type = u32;
    pub const GID: type = u32;
};

pub inline fn statx(directory_FD: i32, path: [*:0]const u8, flags: u32, mask: Statx.Mask, statx_ptr: *Statx) !void {
    const result = syscall_statx(directory_FD, path, flags, mask, statx_ptr);
    if (result < 0) {
        return;
    }
}

// pub const Ring: type = struct {
//     pub const Params: type = extern struct {
//         SQ_entries: u32 = 0,
//         CQ_entries: u32 = 0,
//         flags: Flags = .{},
//         SQ_thread_CPU: u32 = 0,
//         SQ_thread_idle: u32 = 0,
//         features: Features = .{},
//         WQ_FD: i32 = 0,
//         reserved_1: [3]u32 = .{ 0, 0, 0 },
//         SQ_ring_offsets: SQRingOffsets = .{},
//         CQ_ring_offsets: CQRingOffsets = .{},

//         pub const Flags: type = packed struct(u32) {
//             IO_poll: bool = false,
//             SQ_poll: bool = false,
//             SQ_affinity: bool = false,
//             CQ_entries: bool = false,
//             clamp: bool = false,
//             attach_WQ: bool = false,
//             disabled: bool = false,
//             submit_all: bool = false,
//             cooperative_taskrun: bool = false,
//             taskrun_flag: bool = false,
//             SQE128: bool = false,
//             CQE32: bool = false,
//             single_issuer: bool = false,
//             defer_taskrun: bool = false,
//             no_mmap: bool = false,
//             registered_FD_only: bool = false,
//             no_SQ_array: bool = false,
//             reserved_1: u15 = 0,
//         };

//         pub const Features = packed struct(u32) {
//             single_mmap: bool = false,
//             nodrop: bool = false,
//             submit_stable: bool = false,
//             RW_current_position: bool = false,
//             current_personality: bool = false,
//             fast_poll: bool = false,
//             poll_32bits: bool = false,
//             SQpoll_nonfixed: bool = false,
//             extended_arguments: bool = false,
//             native_workers: bool = false,
//             resource_tags: bool = false,
//             CQE_skip: bool = false,
//             linked_file: bool = false,
//             register_ring_in_ring: bool = false,
//             recvsend_bundle: bool = false,
//             reserved_1: u17 = 0,
//         };

//         pub const SQRingOffsets: type = extern struct {
//             head: u32 = 0,
//             tail: u32 = 0,
//             ring_mask: u32 = 0,
//             ring_entries: u32 = 0,
//             flags: u32 = 0,
//             dropped: u32 = 0,
//             array: u32 = 0,
//             reserved_1: u32 = 0,
//             user_addr: u64 = 0,
//         };

//         pub const CQRingOffsets: type = extern struct {
//             head: u32 = 0,
//             tail: u32 = 0,
//             ring_mask: u32 = 0,
//             ring_entries: u32 = 0,
//             overflow: u32 = 0,
//             cqes: u32 = 0,
//             flags: u32 = 0,
//             reserved_1: u32 = 0,
//             user_addr: u64 = 0,
//         };
//     };

//     pub const SQE: type = extern struct {
//         opcode: Opcode = .nop,
//         flags: u8 = 0,
//         ioprio: u16 = 0,
//         FD: i32 = 0,
//         union_1: extern union {
//             offset: u64,
//             address_2: u64,
//             unnamed_0: extern struct {
//                 cmd_op: u32 = 0,
//                 padding_1: u32 = 0,
//             },
//         },
//         union_2: extern union {
//             address: u64,
//             splice_off_in: u64,
//             unnamed_0: extern struct {
//                 level: u32 = 0,
//                 optname: u32 = 0,
//             },
//         },
//         length: u32 = 0,
//         union_3: extern union {
//             rw_flags: i32,
//             fsync_flags: u32,
//             poll_events: u16,
//             poll32_events: u32,
//             sync_range_flags: u32,
//             msg_flags: u32,
//             timeout_flags: u32,
//             accept_flags: u32,
//             cancel_flags: u32,
//             open_flags: u32,
//             statx_flags: u32,
//             fadvise_advice: u32,
//             splice_flags: u32,
//             rename_flags: u32,
//             unlink_flags: u32,
//             hardlink_flags: u32,
//             xattr_flags: u32,
//             msg_ring_flags: u32,
//             uring_cmd_flags: u32,
//             waitid_flags: u32,
//             futex_flags: u32,
//             install_fd_flags: u32,
//             nop_flags: u32,
//         },
//         user_data: u64 = 0,
//         union_4: extern union {
//             buf_index: u16 align(1),
//             buf_group: u16 align(1),
//         },
//         personality: u16 = 0,
//         union_5: extern union {
//             splice_fd_in: i32,
//             file_index: u32,
//             optlen: u32,
//             unnamed_1: extern struct {
//                 address_len: u16 = 0,
//                 padding_3: [1]u16 = .{0},
//             },
//         },
//         union_6: extern union {
//             unnamed_1: extern struct {
//                 address_3: u64 = 0,
//                 padding_2: [1]u64 = .{0},
//             } align(8),
//             optval: u64,
//         },
//     };

//     pub const SQE128: type = extern struct {
//         SQE: SQE,
//     };

//     pub const CQE: type = extern struct {
//         user_data: u64 align(8) = 0,
//         result: i32 = 0,
//         flags: u32 = 0,
//     };

//     pub const CQE32: type = extern struct {
//         CQE: CQE,
//         reserved_1: [2]u64 = 0,
//     };

//     pub const Opcode: type = enum(u8) {
//         nop,
//         readv,
//         writev,
//         fsync,
//         read_fixed,
//         write_fixed,
//         poll_add,
//         poll_remove,
//         sync_file_range,
//         sendmsg,
//         recvmsg,
//         timeout,
//         timeout_remove,
//         accept,
//         async_cancel,
//         link_timeout,
//         connect,
//         fallocate,
//         openat,
//         close,
//         files_update,
//         statx,
//         read,
//         write,
//         fadvise,
//         madvise,
//         send,
//         recv,
//         openat2,
//         epoll_ctl,
//         splice,
//         provide_buffers,
//         remove_buffers,
//         tee,
//         shutdown,
//         renameat,
//         unlinkat,
//         mkdirat,
//         symlinkat,
//         linkat,
//         msg_ring,
//         fsetxattr,
//         setxattr,
//         fgetxattr,
//         getxattr,
//         socket,
//         uring_cmd,
//         send_zc,
//         sendmsg_zc,
//         read_multishot,
//         waitid,
//         futex_wait,
//         futex_wake,
//         futex_waitv,
//         fixed_fd_install,
//         ftruncate,
//         last,
//     };

//     pub const EnterFlags: type = packed struct(u32) {
//         getevents: bool = false,
//         SQ_wakeup: bool = false,
//         SQ_wait: bool = false,
//         extended_argument: bool = false,
//         registered_ring: bool = false,
//         reserved_1: u27 = 0,
//     };

//     pub const SQFlags: type = packed struct(u32) {
//         SQ_need_wakeup: bool = false,
//         SQ_CQ_overflow: bool = false,
//         SQ_taskrun: bool = false,
//         reserved_1: u29 = 0,
//     };

//     pub const RingError: type = error{
//         Setup,
//         Enter,
//     };

//     pub const SQ_ring_offset: usize = 0;
//     pub const CQ_ring_offset: usize = 0x8000000;
//     pub const SQ_SQEs_offset: usize = 0x10000000;

//     const s = @extern(*fn (entries: u32, params_ptr: *Params) i32, .{ .name = "setup" });

//     pub fn setup(entries: u32, params_ptr: *Params) !i32 {
//         const result: isize = @bitCast(linux.syscall2(
//             .io_uring_setup,
//             entries,
//             @intFromPtr(params_ptr),
//         ));
//         if (result < 0) return RingError.Setup else return @intCast(result);
//     }

//     pub fn enter(FD: i32, flushed: u32, at_least: u32, flags: EnterFlags, argp: *allowzero anyopaque, argsz: usize) !i32 {
//         const result: isize = @bitCast(linux.syscall6(
//             .io_uring_enter,
//             @intCast(FD),
//             flushed,
//             at_least,
//             @as(u32, @bitCast(flags)),
//             @intFromPtr(argp),
//             argsz,
//         ));
//         if (result < 0) return RingError.Enter else return @intCast(result);
//     }
// };

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("syscall_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn syscall_mmap(address: ?[*]u8, length: usize, prot: usize, flags: Mmap.Flags, fd: i32, offset: i64) callconv(.SysV) usize;
extern fn syscall_munmap(ptr: [*]const u8, len: usize) callconv(.SysV) isize;
extern fn syscall_openat(directory_FD: i32, path: [*:0]const u8, flags: Openat.Flags, mode: Openat.Mode) callconv(.SysV) i32;
extern fn syscall_close(FD: i32) callconv(.SysV) isize;
extern fn syscall_statx(directory_FD: i32, path: [*:0]const u8, flags: u32, mask: Statx.Mask, statx_ptr: *Statx) callconv(.SysV) isize;
extern fn syscall_read(FD: i32, buffer_ptr: [*]u8, buffer_len: usize) callconv(.SysV) i32;
extern fn syscall_write(FD: i32, buffer_ptr: [*]u8, buffer_len: usize) callconv(.SysV) i32;
// extern fn syscall_socket(domain: u32, socket_type: u32, protocol: u32) callconv(.SysV) i32;
// extern fn syscall_bind(FD: i32, address: ?*linux.sockaddr, address_length: ?*linux.socklen_t) callconv(.SysV) isize;
// extern fn syscall_listen(FD: i32, backlog: i32) callconv(.SysV) isize;
// extern fn syscall_accept4(FD: i32, address: ?*linux.sockaddr, address_length: ?*linux.socklen_t, flags: u32) callconv(.SysV) i32;
// extern fn syscall_recvfrom(FD: i32, buffer_ptr: [*]u8, buffer_len: usize, flags: u32, address: ?*linux.sockaddr, address_length: ?*linux.socklen_t) callconv(.SysV) i32;
// extern fn syscall_sendto(FD: i32, buffer_ptr: [*]u8, buffer_len: usize, flags: u32, address: ?*linux.sockaddr, address_length: ?*linux.socklen_t) callconv(.SysV) i32;
