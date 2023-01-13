use std::task::Poll;

use anyhow::anyhow;
use futures::*;
use tokio::net::{TcpStream, TcpListener};
use tokio_tungstenite::{connect_async, WebSocketStream, MaybeTlsStream, accept_async, tungstenite};

pub struct Transport {
    sock: Sock,
}

// receive
impl Stream for Transport {
    type Item = Message;

    fn poll_next(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> task::Poll<Option<Self::Item>> {
        match self.sock.poll_next_unpin(cx) {
            Poll::Ready(v) => Poll::Ready(match v {
                Some(v) => match v {
                    Ok(v) => Message::try_from(v).ok(),
                    Err(_) => None,
                },
                None => None,
            }),
            Poll::Pending => Poll::Pending,
        }
    }
}

// send
impl Sink<Message> for Transport {
    type Error = tungstenite::Error;

    fn poll_ready(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.sock.poll_ready_unpin(cx)
    }

    fn start_send(mut self: std::pin::Pin<&mut Self>, item: Message) -> Result<(), Self::Error> {
        self.sock.start_send_unpin(item.into())
    }

    fn poll_flush(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.sock.poll_flush_unpin(cx)
    }

    fn poll_close(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.sock.poll_close_unpin(cx)
    }

    
}

// constructors
impl Transport {
    pub async fn connect(ip: String, port: u16) -> anyhow::Result<Self> {
        let (sock, _) = connect_async(format!("ws://{ip}:{port}")).await?;
        Ok(Self::new(sock))
    }

    pub async fn receive(listener: TcpListener) -> anyhow::Result<Self> {
        let (stream, _) = listener.accept().await?;
        let sock = accept_async(MaybeTlsStream::Plain(stream)).await?;
        Ok(Self::new(sock))
    }

    fn new(sock: Sock) -> Self {
        Self {
            sock,
        }
    }
}

type Sock = WebSocketStream<MaybeTlsStream<TcpStream>>;

pub enum Message {
    // data received
    Data(Vec<u8>),
    // latency testing
    Ping,
    Pong,
    // signal end
    Close,
}

impl TryFrom<tungstenite::Message> for Message {
    type Error = anyhow::Error;

    fn try_from(message: tungstenite::Message) -> Result<Self, Self::Error> {
        match message {
            tungstenite::Message::Binary(data) => Ok(Message::Data(data)),
            tungstenite::Message::Text(text) => Ok(Message::Data(text.into_bytes())),
            tungstenite::Message::Ping(_) => Ok(Message::Ping),
            tungstenite::Message::Pong(_) => Ok(Message::Pong),
            tungstenite::Message::Close(_) => Ok(Message::Close),
            _ => Err(anyhow!("invalid message")),
        }
    }
}

impl Into<tungstenite::Message> for Message {
    fn into(self) -> tungstenite::Message {
        match self {
            Message::Data(data) => tungstenite::Message::Binary(data),
            Message::Ping => tungstenite::Message::Ping(Vec::default()),
            Message::Pong => tungstenite::Message::Pong(Vec::default()),
            Message::Close => tungstenite::Message::Close(None),
        }
    }
}