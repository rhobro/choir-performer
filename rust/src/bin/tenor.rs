use chrono::Utc;
use tokio::net::{TcpListener, TcpStream};
use tokio_tungstenite::{accept_async, tungstenite::Message};
use futures::*;

async fn handle(stream: TcpStream) -> anyhow::Result<()> {
    // convert to websocket
    let mut sock = accept_async(stream).await?;
    
    while let Some(message) = sock.next().await {
        match message? {
            // data
            Message::Binary(_) => todo!(),

            // receive ping
            Message::Ping(_) => {
                println!("received ping at {}", Utc::now());
                sock.send(Message::Pong(Vec::default())).await?;
            },

            // close
            Message::Close(_) => break,
            _ => {},
        }
    }

    Ok(())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // bind
    let listener = TcpListener::bind("127.0.0.1:5050").await?;

    // one conn at a time
    while let Ok((stream, _)) = listener.accept().await {
        handle(stream).await?;
    }

    Ok(())
}