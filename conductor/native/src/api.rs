use std::net::TcpStream;
pub use std::sync::RwLock;
use chrono::{DateTime, Utc};
use flutter_rust_bridge::{RustOpaque, SyncReturn, StreamSink};
use tungstenite::{connect, stream::MaybeTlsStream, WebSocket, Message};
use url::Url;

pub struct RawSpeaker {
    ip: String,
    conn: Option<WebSocket<MaybeTlsStream<TcpStream>>>,

    last_ping: DateTime<Utc>,
}

// constructor
// non blocking
pub fn speaker_new(ip: String) -> anyhow::Result<SyncReturn<RustOpaque<RwLock<RawSpeaker>>>> {
    Ok(SyncReturn(RustOpaque::new(RwLock::new(RawSpeaker {
        ip,
        conn: None,
        last_ping: Utc::now(),
    }))))
}

// connect
// open stream
pub fn speaker_connect(x: RustOpaque<RwLock<RawSpeaker>>, sink: StreamSink<Update>) -> anyhow::Result<()> {
    let mut x = x.write().unwrap();

    // connect
    let (conn, _) = connect(Url::parse(&format!("ws://{}", x.ip))?)?;
    x.conn = Some(conn);

    // check connected
    loop {
        let message = x.conn.as_mut().unwrap().read_message()?;

        // check message
        match message {
            // data
            Message::Binary(_) => todo!(),

            // received response to ping
            Message::Pong(_) => {
                let delta = Utc::now() - x.last_ping;
                sink.add(Update::Ping(Ping(delta.num_milliseconds())));
            },

            // close TODO notify gui
            Message::Close(_) => break,
            _ => {},
        }
    }

    sink.close();
    Ok(())
}

// alive connection?
// non blocking
pub fn speaker_is_connected(x: RustOpaque<RwLock<RawSpeaker>>) -> anyhow::Result<SyncReturn<bool>> {
    let x = x.read().unwrap();

    Ok(SyncReturn(x.conn.is_some()))
}

// send ping request
pub fn speaker_ping(x: RustOpaque<RwLock<RawSpeaker>>) -> anyhow::Result<()> {
    let mut x = x.write().unwrap();

    x.last_ping = Utc::now();
    x.conn.as_mut().unwrap().write_message(Message::Ping(Vec::default()))?;
    
    Ok(())
}

// structs for Dart side

pub enum Update {

    // properties
    Info(MachineInfo),
    Ping(Ping),
}

pub struct MachineInfo {
    pub hostname: String,
    pub mac: String,
    pub os: String,
}

pub struct Ping(pub i64);