use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_speaker_new(port_: i64, ip: *mut wire_uint_8_list) {
    wire_speaker_new_impl(port_, ip)
}

#[no_mangle]
pub extern "C" fn wire_speaker_connect(port_: i64, x: wire_RwLockRawSpeaker) {
    wire_speaker_connect_impl(port_, x)
}

#[no_mangle]
pub extern "C" fn wire_speaker_is_connected(port_: i64, x: wire_RwLockRawSpeaker) {
    wire_speaker_is_connected_impl(port_, x)
}

#[no_mangle]
pub extern "C" fn wire_speaker_get_info(port_: i64, x: wire_RwLockRawSpeaker) {
    wire_speaker_get_info_impl(port_, x)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_RwLockRawSpeaker() -> wire_RwLockRawSpeaker {
    wire_RwLockRawSpeaker::new_with_null_ptr()
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

#[no_mangle]
pub extern "C" fn drop_opaque_RwLockRawSpeaker(ptr: *const c_void) {
    unsafe {
        Arc::<RwLock<RawSpeaker>>::decrement_strong_count(ptr as _);
    }
}

#[no_mangle]
pub extern "C" fn share_opaque_RwLockRawSpeaker(ptr: *const c_void) -> *const c_void {
    unsafe {
        Arc::<RwLock<RawSpeaker>>::increment_strong_count(ptr as _);
        ptr
    }
}

// Section: impl Wire2Api

impl Wire2Api<RustOpaque<RwLock<RawSpeaker>>> for wire_RwLockRawSpeaker {
    fn wire2api(self) -> RustOpaque<RwLock<RawSpeaker>> {
        unsafe { support::opaque_from_dart(self.ptr as _) }
    }
}
impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_RwLockRawSpeaker {
    ptr: *const core::ffi::c_void,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_RwLockRawSpeaker {
    fn new_with_null_ptr() -> Self {
        Self {
            ptr: core::ptr::null(),
        }
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
