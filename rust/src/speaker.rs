use chrono::{DateTime, Utc};
use futures::*;
use tokio::net::TcpStream;
use tokio_tungstenite::{connect_async, tungstenite::Message, WebSocketStream, MaybeTlsStream};

pub struct Speaker {
    ip: String,
    conn: Option<Sock>,

    last_ping: DateTime<Utc>,
}

impl Speaker {
    pub fn new(ip: String) -> Self {
        Self {
            ip,
            conn: None,
            last_ping: Utc::now(),
        }
    }

    // TODO stream
    pub async fn connect(&mut self) -> anyhow::Result<()> {
        // check if required TODO

        // connect
        let (mut conn, _) = connect_async(format!("ws://{}:5050", self.ip)).await?;
        self.conn = Some(conn);
        self.ping().await?;

        while let Some(message) = self.conn().next().await {
            match message? {
                // data
                Message::Binary(_) => todo!(),

                // received ping response
                Message::Pong(_) => {
                    println!("received pong at {}", Utc::now());
                    self.ping().await?;
                },

                // close
                Message::Close(_) => {
                    break;
                },
                _ => {},
            }
        }

        Ok(())
    }

    pub fn is_connected(&self) -> bool {
        self.conn.is_some()
    }

    pub async fn ping(&mut self) -> anyhow::Result<()> {
        self.conn().send(Message::Ping(Vec::default())).await?;

        Ok(())
    }

    async fn close(&mut self) -> anyhow::Result<()> {
        self.conn().close(None).await?;
        self.conn = None;

        Ok(())
    }

    fn conn(&mut self) -> &mut Sock {
        self.conn.as_mut().unwrap()
    }
}

type Sock = WebSocketStream<MaybeTlsStream<TcpStream>>;