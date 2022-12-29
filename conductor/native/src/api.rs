pub use std::sync::RwLock;

use flutter_rust_bridge::RustOpaque;
use rand::{distributions::Standard, prelude::*, Rng};

pub struct RawSpeaker {
    ip: String,
    conn: bool,
}

pub fn speaker_new(ip: String) -> anyhow::Result<RustOpaque<RwLock<RawSpeaker>>> {
    Ok(RustOpaque::new(RwLock::new(RawSpeaker { ip, conn: false })))
}

pub fn speaker_connect(x: RustOpaque<RwLock<RawSpeaker>>) -> anyhow::Result<()> {
    let mut x = x.write().unwrap();

    x.conn = rand::thread_rng().gen_bool(0.7);
    Ok(())
}

// alive connection?
pub fn speaker_is_connected(x: RustOpaque<RwLock<RawSpeaker>>) -> anyhow::Result<bool> {
    let x = x.read().unwrap();

    Ok(x.conn)
}

// get current state
// only available if connected
pub fn speaker_get_info(x: RustOpaque<RwLock<RawSpeaker>>) -> anyhow::Result<Option<MachineInfo>> {
    let x = x.read().unwrap();
    let i = x.ip.split(".").last().unwrap().parse::<u32>().unwrap() % 3;

    Ok(if x.conn {
        Some(MachineInfo {
            hostname: format!("Device {}", x.ip.chars().last().unwrap()),
            os: match i {
                0 => OS::MacOS,
                1 => OS::Windows,
                _ => OS::Linux,
            },
        })
    } else {
        None
    })
}

// test latency
pub fn speaker_ping(x: RustOpaque<RwLock<RawSpeaker>>) -> anyhow::Result<f64> {
    let x = x.write().unwrap();
    
    Ok(rand::thread_rng().gen())
}

pub struct MachineInfo {
    pub hostname: String,
    pub os: OS,
}

pub enum OS {
    MacOS,
    Windows,
    Linux,
}

// allowing random OS choosing for debugging purposes
// TODO remove
impl Distribution<OS> for Standard {
    fn sample<R: Rng + ?Sized>(&self, rng: &mut R) -> OS {
        // match rng.gen_range(0, 3) { // rand 0.5, 0.6, 0.7
        match rng.gen_range(0..2) {
            // rand 0.8
            0 => OS::MacOS,
            1 => OS::Windows,
            _ => OS::Linux,
        }
    }
}
