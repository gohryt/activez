const std = @import("std");

pub const Errno = enum(usize) {
    /// Operation not permitted
    EPERM = 1,
    /// No such file or directory
    ENOENT = 2,
    /// No such process
    ESRCH = 3,
    /// Interrupted system call
    EINTR = 4,
    /// I/O error
    EIO = 5,
    /// No such device or address
    ENXIO = 6,
    /// Argument list too long
    E2BIG = 7,
    /// Exec format error
    ENOEXEC = 8,
    /// Bad file number
    EBADF = 9,

    /// No child processes
    ECHILD = 10,
    /// Try again
    EAGAIN = 11,
    /// Out of memory
    ENOMEM = 12,
    /// Permission denied
    EACCES = 13,
    /// Bad address
    EFAULT = 14,
    /// Block device required
    ENOTBLK = 15,
    /// Device or resource busy
    EBUSY = 16,
    /// File exists
    EEXIST = 17,
    /// Cross-device link
    EXDEV = 18,
    /// No such device
    ENODEV = 19,

    /// Not a directory
    ENOTDIR = 20,
    /// Is a directory
    EISDIR = 21,
    /// Invalid argument
    EINVAL = 22,
    /// File table overflow
    ENFILE = 23,
    /// Too many open files
    EMFILE = 24,
    /// Not a typewriter
    ENOTTY = 25,
    /// Text file busy
    ETXTBSY = 26,
    /// File too large
    EFBIG = 27,
    /// No space left on device
    ENOSPC = 28,
    /// Illegal seek
    ESPIPE = 29,

    /// Read-only file system
    EROFS = 30,
    /// Too many links
    EMLINK = 31,
    /// Broken pipe
    EPIPE = 32,
    /// Math argument out of domain of func
    EDOM = 33,
    /// Math result not representable
    ERANGE = 34,

    /// Resource deadlock would occur
    EDEADLK = 35,
    /// File name too long
    ENAMETOOLONG = 36,
    /// No record locks available
    ENOLCK = 37,
    /// Invalid system call number
    ENOSYS = 38,
    /// Directory not empty
    ENOTEMPTY = 39,

    /// Too many symbolic links encountered
    ELOOP = 40,
    /// No message of desired type
    ENOMSG = 42,
    /// Identifier removed
    EIDRM = 43,
    /// Channel number out of range
    ECHRNG = 44,
    /// Level 2 not synchronized
    EL2NSYNC = 45,
    /// Level 3 halted
    EL3HLT = 46,
    /// Level 3 reset
    EL3RST = 47,
    /// Link number out of range
    ELNRNG = 48,
    /// Protocol driver not attached
    EUNATCH = 49,

    /// No CSI structure available
    ENOCSI = 50,
    /// Level 2 halted
    EL2HLT = 51,
    /// Invalid exchange
    EBADE = 52,
    /// Invalid request descriptor
    EBADR = 53,
    /// Exchange full
    EXFULL = 54,
    /// No anode
    ENOANO = 55,
    /// Invalid request code
    EBADRQC = 56,
    /// Invalid slot
    EBADSLT = 57,
    /// Bad font file format
    EBFONT = 59,

    /// Device not a stream
    ENOSTR = 60,
    /// No data available
    ENODATA = 61,
    /// Timer expired
    ETIME = 62,
    /// Out of streams resources
    ENOSR = 63,
    /// Machine is not on the network
    ENONET = 64,
    /// Package not installed
    ENOPKG = 65,
    /// Object is remote
    EREMOTE = 66,
    /// Link has been severed
    ENOLINK = 67,
    /// Advertise error
    EADV = 68,
    /// Srmount error
    ESRMNT = 69,

    /// Communication error on send
    ECOMM = 70,
    /// Protocol error
    EPROTO = 71,
    /// Multihop attempted
    EMULTIHOP = 72,
    /// RFS specific error
    EDOTDOT = 73,
    /// Not a data message
    EBADMSG = 74,
    /// Value too large for defined data type
    EOVERFLOW = 75,
    /// Name not unique on network
    ENOTUNIQ = 76,
    /// File descriptor in bad state
    EBADFD = 77,
    /// Remote address changed
    EREMCHG = 78,
    /// Can not access a needed shared library
    ELIBACC = 79,

    /// Accessing a corrupted shared library
    ELIBBAD = 80,
    /// .lib section in a.out corrupted
    ELIBSCN = 81,
    /// Attempting to link in too many shared libraries
    ELIBMAX = 82,
    /// Cannot exec a shared library directly
    ELIBEXEC = 83,
    /// Illegal byte sequence
    EILSEQ = 84,
    /// Interrupted system call should be restarted
    ERESTART = 85,
    /// Streams pipe error
    ESTRPIPE = 86,
    /// Too many users
    EUSERS = 87,
    /// Socket operation on non-socket
    ENOTSOCK = 88,
    /// Destination address required
    EDESTADDRREQ = 89,

    /// Message too long
    EMSGSIZE = 90,
    /// Protocol wrong type for socket
    EPROTOTYPE = 91,
    /// Protocol not available
    ENOPROTOOPT = 92,
    /// Protocol not supported
    EPROTONOSUPPORT = 93,
    /// Socket type not supported
    ESOCKTNOSUPPORT = 94,
    /// Operation not supported on transport endpoint
    EOPNOTSUPP = 95,
    /// Protocol family not supported
    EPFNOSUPPORT = 96,
    /// Address family not supported by protocol
    EAFNOSUPPORT = 97,
    /// Address already in use
    EADDRINUSE = 98,
    /// Cannot assign requested address
    EADDRNOTAVAIL = 99,

    /// Network is down
    ENETDOWN = 100,
    /// Network is unreachable
    ENETUNREACH = 101,
    /// Network dropped connection because of reset
    ENETRESET = 102,
    /// Software caused connection abort
    ECONNABORTED = 103,
    /// Connection reset by peer
    ECONNRESET = 104,
    /// No buffer space available
    ENOBUFS = 105,
    /// Transport endpoint is already connected
    EISCONN = 106,
    /// Transport endpoint is not connected
    ENOTCONN = 107,
    /// Cannot send after transport endpoint shutdown
    ESHUTDOWN = 108,
    /// Too many references: cannot splice
    ETOOMANYREFS = 109,

    /// Connection timed out
    ETIMEDOUT = 110,
    /// Connection refused
    ECONNREFUSED = 111,
    /// Host is down
    EHOSTDOWN = 112,
    /// No route to host
    EHOSTUNREACH = 113,
    /// Operation already in progress
    EALREADY = 114,
    /// Operation now in progress
    EINPROGRESS = 115,
    /// Stale file handle
    ESTALE = 116,
    /// Structure needs cleaning
    EUCLEAN = 117,
    /// Not a XENIX named type file
    ENOTNAM = 118,
    /// No XENIX semaphores available
    ENAVAIL = 119,

    /// Is a named type file
    EISNAM = 120,
    /// Remote I/O error
    EREMOTEIO = 121,
    /// Quota exceeded
    EDQUOT = 122,
    /// No medium found
    ENOMEDIUM = 123,
    /// Wrong medium type
    EMEDIUMTYPE = 124,
    /// Operation Canceled
    ECANCELED = 125,
    /// Required key not available
    ENOKEY = 126,
    /// Key has expired
    EKEYEXPIRED = 127,
    /// Key has been revoked
    EKEYREVOKED = 128,
    /// Key was rejected by service
    EKEYREJECTED = 129,

    /// Owner died
    EOWNERDEAD = 130,
    /// State not recoverable
    ENOTRECOVERABLE = 131,
    /// Operation not possible due to RF-kill
    ERFKILL = 132,
    /// Memory page has hardware error
    EHWPOISON = 133,

    pub fn toError(errno: Errno) Error {
        return switch (errno) {
            Errno.EPERM => Error.OperationNotPermitted,
            Errno.ENOENT => Error.NoSuchFileOrDirectory,
            Errno.ESRCH => Error.NoSuchProcess,
            Errno.EINTR => Error.InterruptedSystemCall,
            Errno.EIO => Error.IOError,
            Errno.ENXIO => Error.NoSuchDeviceOrAddress,
            Errno.E2BIG => Error.ArgumentListTooLong,
            Errno.ENOEXEC => Error.ExecFormatError,
            Errno.EBADF => Error.BadFileNumber,
            Errno.ECHILD => Error.NoChildProcesses,
            Errno.EAGAIN => Error.TryAgain,
            Errno.ENOMEM => Error.OutOfMemory,
            Errno.EACCES => Error.PermissionDenied,
            Errno.EFAULT => Error.BadAddress,
            Errno.ENOTBLK => Error.BlockDeviceRequired,
            Errno.EBUSY => Error.DeviceOrResourceBusy,
            Errno.EEXIST => Error.FileExists,
            Errno.EXDEV => Error.CrossDeviceLink,
            Errno.ENODEV => Error.NoSuchDevice,
            Errno.ENOTDIR => Error.NotADirectory,
            Errno.EISDIR => Error.IsADirectory,
            Errno.EINVAL => Error.InvalidArgument,
            Errno.ENFILE => Error.FileTableOverflow,
            Errno.EMFILE => Error.TooManyOpenFiles,
            Errno.ENOTTY => Error.NotATypewriter,
            Errno.ETXTBSY => Error.TextFileBusy,
            Errno.EFBIG => Error.FileTooLarge,
            Errno.ENOSPC => Error.NoSpaceLeftOnDevice,
            Errno.ESPIPE => Error.IllegalSeek,
            Errno.EROFS => Error.ReadOnlyFileSystem,
            Errno.EMLINK => Error.TooManyLinks,
            Errno.EPIPE => Error.BrokenPipe,
            Errno.EDOM => Error.MathArgumentOutOfDomainOfFunc,
            Errno.ERANGE => Error.MathResultNotRepresentable,
            Errno.EDEADLK => Error.ResourceDeadlockWouldOccur,
            Errno.ENAMETOOLONG => Error.FileNameTooLong,
            Errno.ENOLCK => Error.NoRecordLocksAvailable,
            Errno.ENOSYS => Error.InvalidSystemCallNumber,
            Errno.ENOTEMPTY => Error.DirectoryNotEmpty,
            Errno.ELOOP => Error.TooManySymbolicLinksEncountered,
            Errno.ENOMSG => Error.NoMessageOfDesiredType,
            Errno.EIDRM => Error.IdentifierRemoved,
            Errno.ECHRNG => Error.ChannelNumberOutOfRange,
            Errno.EL2NSYNC => Error.Level2NotSynchronized,
            Errno.EL3HLT => Error.Level3Halted,
            Errno.EL3RST => Error.Level3Reset,
            Errno.ELNRNG => Error.LinkNumberOutOfRange,
            Errno.EUNATCH => Error.ProtocolDriverNotAttached,
            Errno.ENOCSI => Error.NoCSIStructureAvailable,
            Errno.EL2HLT => Error.Level2Halted,
            Errno.EBADE => Error.InvalidExchange,
            Errno.EBADR => Error.InvalidRequestDescriptor,
            Errno.EXFULL => Error.ExchangeFull,
            Errno.ENOANO => Error.NoAnode,
            Errno.EBADRQC => Error.InvalidRequestCode,
            Errno.EBADSLT => Error.InvalidSlot,
            Errno.EBFONT => Error.BadFontFileFormat,
            Errno.ENOSTR => Error.DeviceNotAStream,
            Errno.ENODATA => Error.NoDataAvailable,
            Errno.ETIME => Error.TimerExpired,
            Errno.ENOSR => Error.OutOfStreamsResources,
            Errno.ENONET => Error.MachineIsNotOnTheNetwork,
            Errno.ENOPKG => Error.PackageNotInstalled,
            Errno.EREMOTE => Error.ObjectIsRemote,
            Errno.ENOLINK => Error.LinkHasBeenSevered,
            Errno.EADV => Error.AdvertiseError,
            Errno.ESRMNT => Error.SrmountError,
            Errno.ECOMM => Error.CommunicationErrorOnSend,
            Errno.EPROTO => Error.ProtocolError,
            Errno.EMULTIHOP => Error.MultihopAttempted,
            Errno.EDOTDOT => Error.RFSSpecificError,
            Errno.EBADMSG => Error.NotADataMessage,
            Errno.EOVERFLOW => Error.ValueTooLargeForDefinedDataType,
            Errno.ENOTUNIQ => Error.NameNotUniqueOnNetwork,
            Errno.EBADFD => Error.FileDescriptorInBadState,
            Errno.EREMCHG => Error.RemoteAddressChanged,
            Errno.ELIBACC => Error.CannotAccessANeededSharedLibrary,
            Errno.ELIBBAD => Error.AccessingACorruptedSharedLibrary,
            Errno.ELIBSCN => Error.LibSectionInAOutCorrupted,
            Errno.ELIBMAX => Error.AttemptingToLinkInTooManySharedLibraries,
            Errno.ELIBEXEC => Error.CannotExecASharedLibraryDirectly,
            Errno.EILSEQ => Error.IllegalByteSequence,
            Errno.ERESTART => Error.InterruptedSystemCallShouldBeRestarted,
            Errno.ESTRPIPE => Error.StreamsPipeError,
            Errno.EUSERS => Error.TooManyUsers,
            Errno.ENOTSOCK => Error.SocketOperationOnNonSocket,
            Errno.EDESTADDRREQ => Error.DestinationAddressRequired,
            Errno.EMSGSIZE => Error.MessageTooLong,
            Errno.EPROTOTYPE => Error.ProtocolWrongTypeForSocket,
            Errno.ENOPROTOOPT => Error.ProtocolNotAvailable,
            Errno.EPROTONOSUPPORT => Error.ProtocolNotSupported,
            Errno.ESOCKTNOSUPPORT => Error.SocketTypeNotSupported,
            Errno.EOPNOTSUPP => Error.OperationNotSupportedOnTransportEndpoint,
            Errno.EPFNOSUPPORT => Error.ProtocolFamilyNotSupported,
            Errno.EAFNOSUPPORT => Error.AddressFamilyNotSupportedByProtocol,
            Errno.EADDRINUSE => Error.AddressAlreadyInUse,
            Errno.EADDRNOTAVAIL => Error.CannotAssignRequestedAddress,
            Errno.ENETDOWN => Error.NetworkIsDown,
            Errno.ENETUNREACH => Error.NetworkIsUnreachable,
            Errno.ENETRESET => Error.NetworkDroppedConnectionBecauseOfReset,
            Errno.ECONNABORTED => Error.SoftwareCausedConnectionAbort,
            Errno.ECONNRESET => Error.ConnectionResetByPeer,
            Errno.ENOBUFS => Error.NoBufferSpaceAvailable,
            Errno.EISCONN => Error.TransportEndpointIsAlreadyConnected,
            Errno.ENOTCONN => Error.TransportEndpointIsNotConnected,
            Errno.ESHUTDOWN => Error.CannotSendAfterTransportEndpointShutdown,
            Errno.ETOOMANYREFS => Error.TooManyReferencesCannotSplice,
            Errno.ETIMEDOUT => Error.ConnectionTimedOut,
            Errno.ECONNREFUSED => Error.ConnectionRefused,
            Errno.EHOSTDOWN => Error.HostIsDown,
            Errno.EHOSTUNREACH => Error.NoRouteToHost,
            Errno.EALREADY => Error.OperationAlreadyInProgress,
            Errno.EINPROGRESS => Error.OperationNowInProgress,
            Errno.ESTALE => Error.StaleFileHandle,
            Errno.EUCLEAN => Error.StructureNeedsCleaning,
            Errno.ENOTNAM => Error.NotAXENIXNamedTypeFile,
            Errno.ENAVAIL => Error.NoXENIXSemaphoresAvailable,
            Errno.EISNAM => Error.IsANamedTypeFile,
            Errno.EREMOTEIO => Error.RemoteIOError,
            Errno.EDQUOT => Error.QuotaExceeded,
            Errno.ENOMEDIUM => Error.NoMediumFound,
            Errno.EMEDIUMTYPE => Error.WrongMediumType,
            Errno.ECANCELED => Error.OperationCanceled,
            Errno.ENOKEY => Error.RequiredKeyNotAvailable,
            Errno.EKEYEXPIRED => Error.KeyHasExpired,
            Errno.EKEYREVOKED => Error.KeyHasBeenRevoked,
            Errno.EKEYREJECTED => Error.KeyWasRejectedByService,
            Errno.EOWNERDEAD => Error.OwnerDied,
            Errno.ENOTRECOVERABLE => Error.StateNotRecoverable,
            Errno.ERFKILL => Error.OperationNotPossibleDueToRFkill,
            Errno.EHWPOISON => Error.MemoryPageHasHardwareError,
        };
    }
};

pub const Error = error{
    OperationNotPermitted,
    NoSuchFileOrDirectory,
    NoSuchProcess,
    InterruptedSystemCall,
    IOError,
    NoSuchDeviceOrAddress,
    ArgumentListTooLong,
    ExecFormatError,
    BadFileNumber,
    NoChildProcesses,
    TryAgain,
    OutOfMemory,
    PermissionDenied,
    BadAddress,
    BlockDeviceRequired,
    DeviceOrResourceBusy,
    FileExists,
    CrossDeviceLink,
    NoSuchDevice,
    NotADirectory,
    IsADirectory,
    InvalidArgument,
    FileTableOverflow,
    TooManyOpenFiles,
    NotATypewriter,
    TextFileBusy,
    FileTooLarge,
    NoSpaceLeftOnDevice,
    IllegalSeek,
    ReadOnlyFileSystem,
    TooManyLinks,
    BrokenPipe,
    MathArgumentOutOfDomainOfFunc,
    MathResultNotRepresentable,
    ResourceDeadlockWouldOccur,
    FileNameTooLong,
    NoRecordLocksAvailable,
    InvalidSystemCallNumber,
    DirectoryNotEmpty,
    TooManySymbolicLinksEncountered,
    NoMessageOfDesiredType,
    IdentifierRemoved,
    ChannelNumberOutOfRange,
    Level2NotSynchronized,
    Level3Halted,
    Level3Reset,
    LinkNumberOutOfRange,
    ProtocolDriverNotAttached,
    NoCSIStructureAvailable,
    Level2Halted,
    InvalidExchange,
    InvalidRequestDescriptor,
    ExchangeFull,
    NoAnode,
    InvalidRequestCode,
    InvalidSlot,
    BadFontFileFormat,
    DeviceNotAStream,
    NoDataAvailable,
    TimerExpired,
    OutOfStreamsResources,
    MachineIsNotOnTheNetwork,
    PackageNotInstalled,
    ObjectIsRemote,
    LinkHasBeenSevered,
    AdvertiseError,
    SrmountError,
    CommunicationErrorOnSend,
    ProtocolError,
    MultihopAttempted,
    RFSSpecificError,
    NotADataMessage,
    ValueTooLargeForDefinedDataType,
    NameNotUniqueOnNetwork,
    FileDescriptorInBadState,
    RemoteAddressChanged,
    CannotAccessANeededSharedLibrary,
    AccessingACorruptedSharedLibrary,
    LibSectionInAOutCorrupted,
    AttemptingToLinkInTooManySharedLibraries,
    CannotExecASharedLibraryDirectly,
    IllegalByteSequence,
    InterruptedSystemCallShouldBeRestarted,
    StreamsPipeError,
    TooManyUsers,
    SocketOperationOnNonSocket,
    DestinationAddressRequired,
    MessageTooLong,
    ProtocolWrongTypeForSocket,
    ProtocolNotAvailable,
    ProtocolNotSupported,
    SocketTypeNotSupported,
    OperationNotSupportedOnTransportEndpoint,
    ProtocolFamilyNotSupported,
    AddressFamilyNotSupportedByProtocol,
    AddressAlreadyInUse,
    CannotAssignRequestedAddress,
    NetworkIsDown,
    NetworkIsUnreachable,
    NetworkDroppedConnectionBecauseOfReset,
    SoftwareCausedConnectionAbort,
    ConnectionResetByPeer,
    NoBufferSpaceAvailable,
    TransportEndpointIsAlreadyConnected,
    TransportEndpointIsNotConnected,
    CannotSendAfterTransportEndpointShutdown,
    TooManyReferencesCannotSplice,
    ConnectionTimedOut,
    ConnectionRefused,
    HostIsDown,
    NoRouteToHost,
    OperationAlreadyInProgress,
    OperationNowInProgress,
    StaleFileHandle,
    StructureNeedsCleaning,
    NotAXENIXNamedTypeFile,
    NoXENIXSemaphoresAvailable,
    IsANamedTypeFile,
    RemoteIOError,
    QuotaExceeded,
    NoMediumFound,
    WrongMediumType,
    OperationCanceled,
    RequiredKeyNotAvailable,
    KeyHasExpired,
    KeyHasBeenRevoked,
    KeyWasRejectedByService,
    OwnerDied,
    StateNotRecoverable,
    OperationNotPossibleDueToRFkill,
    MemoryPageHasHardwareError,
};

pub const File = struct {
    pub const Control = struct {
        pub const Command = enum(u32) {
            file_get_flags = 3,
            file_set_flags = 4,
        };
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

        pub const AccessMode = enum(u2) {
            r = 0,
            w = 1,
            rw = 2,
        };
    };
};

pub const Mode = packed struct(u32) {
    others: Permissions = .none,
    group: Permissions = .none,
    owner: Permissions = .none,
    sticky: bool = false,
    set_gid: bool = false,
    set_uid: bool = false,
    reserved_1: u17 = 0,

    pub const Permissions = enum(u4) {
        none = 0x0,
        x = 0x1,
        w = 0x2,
        wx = 0x3,
        r = 0x4,
        rx = 0x5,
        rw = 0x6,
        rwx = 0x7,
    };
};

pub const Socket = struct {
    pub const Address = extern struct {
        family_id: Family.ID,
        family: Family,

        pub const Family = extern union {
            // unix: Unix,
            internet4: Internet4,
            // internet6: Internet6,

            pub const ID = enum(u16) {
                unix = 1,
                internet4 = 2,
                internet6 = 10,
            };
        };

        pub const Unix = extern struct {
            path: [108]u8,
        };

        pub const Internet4 = extern struct {
            port: u16,
            address: [4]u8,
            zero: [8]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0 },
        };

        pub const Internet6 = extern struct {
            port: u16,
            flowinfo: u32,
            address: extern union {
                of8: [16]u8,
                of16: [8]u8,
                of32: [4]u8,
            },
            scope_id: u32,
        };
    };

    pub const Flags = packed struct(u32) {
        type: Type = .stream,
        reserved_1: u10 = 0,
        nonblock: bool = false,
        reserved_2: u10 = 0,
        close_on_exec: bool = false,
        reserved_3: u6 = 0,

        pub const Type = enum(u4) {
            stream = 1,
            datagram = 2,
            raw = 3,
            rdm = 4,
            sequence_packet = 5,
            dccp = 6,
            packet = 10,
        };
    };

    pub const Protocol = enum(u32) {
        Default = 0,
        TCP = 6,
        UDP = 17,
    };
};

pub const Map = struct {
    pub const Protection = packed struct(u32) {
        read: bool = false,
        write: bool = false,
        execute: bool = false,
        sem: bool = false,
        reserved_1: u20 = 0,
        grows_down: bool = false,
        grows_up: bool = false,
        reserved_2: u6 = 0,
    };

    pub const Flags = packed struct(u32) {
        type: Type,
        fixed: bool = false,
        anonymous: bool = false,
        @"32bit": bool = false,
        reserved_1: u1 = 0,
        grows_down: bool = false,
        reserved_2: u2 = 0,
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
        reserved_3: u5 = 0,
        uninitialized: bool = false,
        reserved_4: u5 = 0,

        pub const Type = enum(u4) {
            shared = 0x01,
            private = 0x02,
            shared_validate = 0x03,
        };
    };
};

pub const At = packed struct(u32) {
    reserved_1: u8 = 0,
    symlink_nofollow: bool = false,
    removedir: bool = false,
    symlink_follow: bool = false,
    no_automount: bool = false,
    empty_path: bool = false,
    statx: packed struct(u2) {
        force_sync: bool = false,
        dont_sync: bool = false,
    } = .{
        .force_sync = false,
        .dont_sync = false,
    },
    reserved_2: u17 = 0,

    pub const sync_as_stat: At = .{
        .empty_path = false,
        .statx = .{
            .dont_sync = false,
            .force_sync = false,
        },
    };

    pub const sync_as_stat_empty_path: At = .{
        .empty_path = true,
        .statx = .{
            .dont_sync = false,
            .force_sync = false,
        },
    };

    pub const CWD_FD: i32 = -100;
};

pub const Statx = extern struct {
    mask: Mask = .{},
    blksize: u32 = 0,
    attributes: u64 = 0,
    nlink: u32 = 0,
    uid: u32 = 0,
    gid: u32 = 0,
    mode: u16 = 0,
    reserved_1: [1]u16 = undefined,
    ino: u64 = 0,
    size: u64 = 0,
    blocks: u64 = 0,
    attributes_mask: u64 = 0,
    atime: Timestamp = .{},
    btime: Timestamp = .{},
    ctime: Timestamp = .{},
    mtime: Timestamp = .{},
    rdev_major: u32 = 0,
    rdev_minor: u32 = 0,
    dev_major: u32 = 0,
    dev_minor: u32 = 0,
    reserved_2: [14]u64 = undefined,

    pub const Timestamp = extern struct {
        second: i64 = 0,
        nanosecond: u32 = 0,
        reserved_1: u32 = 0,
    };

    pub const Mask = packed struct(u32) {
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
};

pub const result_max: usize = std.math.maxInt(usize) - 4095;

pub inline fn mmap(ptr: ?[*]u8, len: usize, protection: Map.Protection, flags: Map.Flags, FD: i32, offset: i64) usize {
    return syscall_mmap(ptr, len, protection, flags, FD, offset);
}

pub inline fn munmap(ptr: [*]const u8, len: usize) usize {
    return syscall_munmap(ptr, len);
}

pub inline fn openat(directory_FD: i32, path: [*:0]const u8, flags: File.Flags, mode: Mode) usize {
    return syscall_openat(directory_FD, path, flags, mode);
}

pub inline fn statx(directory_FD: i32, path: [*:0]u8, flags: At, mask: Statx.Mask, statx_ptr: *Statx) usize {
    return syscall_statx(directory_FD, path, flags, mask, statx_ptr);
}

pub inline fn read(FD: i32, buffer: []u8) usize {
    return syscall_read(FD, buffer.ptr, buffer.len);
}

pub inline fn write(FD: i32, buffer: []u8) usize {
    return syscall_write(FD, buffer.ptr, buffer.len);
}

pub inline fn socket(family_id: Socket.Address.Family.ID, flags: Socket.Flags, protocol: Socket.Protocol) usize {
    return syscall_socket(family_id, flags, protocol);
}

pub inline fn bind(FD: i32, address_ptr: *Socket.Address, address_len: u32) usize {
    return syscall_bind(FD, address_ptr, address_len);
}

pub inline fn listen(FD: i32, backlog: u32) usize {
    return syscall_listen(FD, backlog);
}

pub inline fn accept(FD: i32, address_ptr_nullable: ?*Socket.Address, address_len_ptr_nullable: ?*u32, flags: u32) usize {
    return syscall_accept4(FD, address_ptr_nullable, address_len_ptr_nullable, flags);
}

pub inline fn recv(FD: i32, buffer: []u8, flags: u32, address_ptr_nullable: ?*Socket.Address, address_len_ptr_nullable: ?*u32) usize {
    return syscall_recvfrom(FD, buffer.ptr, buffer.len, flags, address_ptr_nullable, address_len_ptr_nullable);
}

pub inline fn send(FD: i32, buffer: []u8, flags: u32, address_ptr_nullable: ?*Socket.Address, address_len_ptr_nullable: u32) usize {
    return syscall_sendto(FD, buffer.ptr, buffer.len, flags, address_ptr_nullable, address_len_ptr_nullable);
}

pub inline fn close(FD: i32) usize {
    return syscall_close(FD);
}

pub const Ring = struct {
    pub const SubmissionQueue = struct {
        pub const RingOffsets = extern struct {
            head: u32 = 0,
            tail: u32 = 0,
            ring_mask: u32 = 0,
            ring_entries: u32 = 0,
            flags: u32 = 0,
            dropped: u32 = 0,
            array: u32 = 0,
            reserved_1: u32 = 0,
            user_addr: u64 = 0,
        };

        pub const Entry = extern struct {
            opcode: Opcode = .nop,
            flags: u8 = 0,
            ioprio: u16 = 0,
            FD: i32 = 0,
            union_1: extern union {
                offset: u64,
                address_2: u64,
                unnamed_0: extern struct {
                    cmd_op: u32 = 0,
                    padding_1: u32 = 0,
                },
            } = .{ .offset = 0 },
            union_2: extern union {
                address: u64,
                splice_off_in: u64,
                unnamed_0: extern struct {
                    level: u32 = 0,
                    optname: u32 = 0,
                },
            } = .{ .address = 0 },
            length: u32 = 0,
            union_3: extern union {
                msg_flags: u32,
                accept_flags: u32,
                file_flags: File.Flags,
                statx_flags: u32,
                nop_flags: u32,
            } = .{ .nop_flags = 0 },
            user_data: u64 = 0,
            union_4: extern union {
                buf_index: u16 align(1),
                buf_group: u16 align(1),
            } = .{ .buf_index = 0 },
            personality: u16 = 0,
            union_5: extern union {
                splice_fd_in: i32,
                file_index: u32,
                optlen: u32,
                unnamed_1: extern struct {
                    address_len: u16 = 0,
                    padding_3: [1]u16 = .{0},
                },
            } = .{ .splice_fd_in = 0 },
            union_6: extern union {
                unnamed_1: extern struct {
                    address_3: u64 = 0,
                    padding_2: [1]u64 = .{0},
                } align(8),
                optval: u64,
            } = .{ .optval = 0 },
        };

        pub const Flags = packed struct(u32) {
            need_wakeup: bool = false,
            overflow: bool = false,
            taskrun: bool = false,
            reserved_1: u29 = 0,
        };
    };

    pub const CompletionQueue = struct {
        pub const RingOffsets = extern struct {
            head: u32 = 0,
            tail: u32 = 0,
            ring_mask: u32 = 0,
            ring_entries: u32 = 0,
            overflow: u32 = 0,
            cqes: u32 = 0,
            flags: u32 = 0,
            reserved_1: u32 = 0,
            user_addr: u64 = 0,
        };

        pub const Entry = extern struct {
            user_data: u64 align(8) = 0,
            result: i32 = 0,
            flags: u32 = 0,
        };
    };

    pub const Params = extern struct {
        submission_queue_entries: u32 = 0,
        completion_queue_entries: u32 = 0,
        flags: Flags = .{},
        submission_queue_thread_CPU: u32 = 0,
        submission_queue_thread_idle: u32 = 0,
        features: Features = .{},
        work_queue_FD: i32 = 0,
        reserved_1: [3]u32 = .{ 0, 0, 0 },
        submission_queue_ring_offsets: SubmissionQueue.RingOffsets = .{},
        completion_queue_ring_offsets: CompletionQueue.RingOffsets = .{},

        pub const Flags = packed struct(u32) {
            IO_poll: bool = false,
            SQ_poll: bool = false,
            SQ_affinity: bool = false,
            CQ_entries: bool = false,
            clamp: bool = false,
            attach_WQ: bool = false,
            disabled: bool = false,
            submit_all: bool = false,
            cooperative_taskrun: bool = false,
            taskrun_flag: bool = false,
            SQE128: bool = false,
            CQE32: bool = false,
            single_issuer: bool = false,
            defer_taskrun: bool = false,
            no_mmap: bool = false,
            registered_FD_only: bool = false,
            no_SQ_array: bool = false,
            reserved_1: u15 = 0,
        };

        pub const Features = packed struct(u32) {
            single_mmap: bool = false,
            nodrop: bool = false,
            submit_stable: bool = false,
            RW_current_position: bool = false,
            current_personality: bool = false,
            fast_poll: bool = false,
            poll_32bits: bool = false,
            SQpoll_nonfixed: bool = false,
            extended_arguments: bool = false,
            native_workers: bool = false,
            resource_tags: bool = false,
            CQE_skip: bool = false,
            linked_file: bool = false,
            register_ring_in_ring: bool = false,
            recvsend_bundle: bool = false,
            reserved_1: u17 = 0,
        };
    };

    pub const Opcode = enum(u8) {
        nop,
        readv,
        writev,
        fsync,
        read_fixed,
        write_fixed,
        poll_add,
        poll_remove,
        sync_file_range,
        sendmsg,
        recvmsg,
        timeout,
        timeout_remove,
        accept,
        async_cancel,
        link_timeout,
        connect,
        fallocate,
        openat,
        close,
        files_update,
        statx,
        read,
        write,
        fadvise,
        madvise,
        send,
        recv,
        openat2,
        epoll_ctl,
        splice,
        provide_buffers,
        remove_buffers,
        tee,
        shutdown,
        renameat,
        unlinkat,
        mkdirat,
        symlinkat,
        linkat,
        msg_ring,
        fsetxattr,
        setxattr,
        fgetxattr,
        getxattr,
        socket,
        uring_cmd,
        send_zc,
        sendmsg_zc,
        read_multishot,
        waitid,
        futex_wait,
        futex_wake,
        futex_waitv,
        fixed_fd_install,
        ftruncate,
        last,
    };

    pub const EnterFlags = packed struct(u32) {
        getevents: bool = false,
        SQ_wakeup: bool = false,
        SQ_wait: bool = false,
        extended_argument: bool = false,
        registered_ring: bool = false,
        reserved_1: u27 = 0,
    };

    pub const SQ_ring_offset: usize = 0;
    pub const CQ_ring_offset: usize = 0x8000000;
    pub const SQ_SQEs_offset: usize = 0x10000000;

    pub inline fn setup(entries: u32, params_ptr: *Params) usize {
        return syscall_ring_setup(entries, params_ptr);
    }

    pub inline fn enter(FD: i32, flushed: u32, at_least: u32, flags: EnterFlags, argp: *allowzero anyopaque, argsz: usize) usize {
        return syscall_ring_enter(FD, flushed, at_least, flags, argp, argsz);
    }
};

pub inline fn fcntl(FD: i32, command: File.Control.Command, argument: File.Flags) usize {
    return syscall_fcntl(FD, command, argument);
}

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("syscall_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn syscall_mmap(ptr: ?[*]u8, len: usize, protection: Map.Protection, flags: Map.Flags, FD: i32, offset: usize) callconv(.SysV) usize;
extern fn syscall_munmap(ptr: [*]const u8, len: usize) callconv(.SysV) usize;
extern fn syscall_openat(directory_FD: i32, path: [*:0]const u8, flags: File.Flags, mode: Mode) callconv(.SysV) usize;
extern fn syscall_close(FD: i32) callconv(.SysV) usize;
extern fn syscall_statx(directory_FD: i32, path: [*:0]allowzero const u8, flags: At, mask: Statx.Mask, statx_ptr: *Statx) callconv(.SysV) usize;
extern fn syscall_read(FD: i32, buffer_ptr: [*]u8, buffer_len: usize) callconv(.SysV) usize;
extern fn syscall_write(FD: i32, buffer_ptr: [*]u8, buffer_len: usize) callconv(.SysV) usize;
extern fn syscall_socket(family_id: Socket.Address.Family.ID, flags: Socket.Flags, protocol: Socket.Protocol) callconv(.SysV) usize;
extern fn syscall_bind(FD: i32, address_ptr_nullable: ?*Socket.Address, address_len: u32) callconv(.SysV) usize;
extern fn syscall_listen(FD: i32, backlog: u32) callconv(.SysV) usize;
extern fn syscall_accept4(FD: i32, address_ptr_nullable: ?*Socket.Address, address_len_ptr_nullable: ?*u32, flags: u32) callconv(.SysV) usize;
extern fn syscall_recvfrom(FD: i32, buffer_ptr: [*]u8, buffer_len: usize, flags: u32, address_ptr_nullable: ?*Socket.Address, address_len_ptr_nullable: ?*u32) callconv(.SysV) usize;
extern fn syscall_sendto(FD: i32, buffer_ptr: [*]u8, buffer_len: usize, flags: u32, address_ptr_nullable: ?*Socket.Address, address_len: u32) callconv(.SysV) usize;
extern fn syscall_ring_setup(entries: u32, params_ptr: *Ring.Params) callconv(.SysV) usize;
extern fn syscall_ring_enter(FD: i32, flushed: u32, at_least: u32, flags: Ring.EnterFlags, argp: *allowzero anyopaque, argsz: usize) callconv(.SysV) usize;
extern fn syscall_fcntl(FD: i32, command: File.Control.Command, argument: File.Flags) callconv(.SysV) usize;
