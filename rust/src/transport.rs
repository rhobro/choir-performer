use std::task::Poll;
use bytes::Bytes;
use futures::*;
use tokio::net::TcpStream;
use tokio_tungstenite::{connect_async, WebSocketStream, MaybeTlsStream, accept_async, tungstenite};

pub struct Transport {
    sock: Sock,
}

// receive
impl Stream for Transport {
    type Item = Bytes;

    fn poll_next(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> task::Poll<Option<Self::Item>> {
        match self.sock.poll_next_unpin(cx) {
            Poll::Ready(v) => Poll::Ready(match v {
                Some(v) => match v {
                    Ok(v) => v.into_data().into(),
                    Err(_) => None,
                },
                None => None,
            }),
            Poll::Pending => Poll::Pending,
        }
    }
}

// send
impl Sink<Bytes> for Transport {
    type Error = tungstenite::Error;

    fn poll_ready(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.sock.poll_ready_unpin(cx)
    }

    fn start_send(mut self: std::pin::Pin<&mut Self>, item: Bytes) -> Result<(), Self::Error> {
        self.sock.start_send_unpin(item.into())
    }

    fn poll_flush(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.sock.poll_flush_unpin(cx)
    }

    fn poll_close(mut self: std::pin::Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.sock.poll_close_unpin(cx)
    }
}

// main
impl Transport {
    pub async fn connect(ip: String, port: u16) -> anyhow::Result<Self> {
        let (sock, _) = connect_async(format!("ws://{ip}:{port}")).await?;
        Ok(Self::new(sock))
    }

    pub async fn receive(stream: TcpStream) -> anyhow::Result<Self> {
        let sock = accept_async(MaybeTlsStream::Plain(stream)).await?;
        Ok(Self::new(sock))
    }

    fn new(sock: Sock) -> Self {
        Self {
            sock,
        }
    }

    pub async fn close(&mut self) -> anyhow::Result<()> {
        Ok(self.sock.close(None).await?)
    }
}

type Sock = WebSocketStream<MaybeTlsStream<TcpStream>>;