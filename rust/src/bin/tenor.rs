use std::io::Cursor;

use choir::{Transport, Frame, Action};
use futures::*;
use rodio::{OutputStream, Sink, Decoder};
use tokio::net::TcpListener;
use prost::Message;

struct Speaker {
    out: OutputStream,
    sink: Sink,
}

impl Speaker {
    fn new() -> Self {
        let (out, handle) = OutputStream::try_default()
            .expect("no audio output available");
        let sink = Sink::try_new(&handle).unwrap();
        Self {
            out,
            sink,
        }
    }

    fn perform(&self, a: Action) -> anyhow::Result<()> {
        match a.action.unwrap() {
            choir::action::Action::Play(play) => {
                // decode
                let audio = Decoder::new(Cursor::new(play.data))?;
                self.sink.append(audio);
                self.sink.play();
            },
            choir::action::Action::Pause(_) => {
                self.sink.pause();
                self.sink.stop();
            },
        }

        Ok(())
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // bind
    let listener = TcpListener::bind("127.0.0.1:5050").await?;
    // init speaker output
    let speaker = Speaker::new();

    // one conn at a time
    while let Ok((stream, _)) = listener.accept().await {
        // convert to websocket
        let mut sock = Transport::receive(stream).await?;

        while let Some(message) = sock.next().await {
            match message {
                // data
                Frame::Data(buf) => {
                    let action = Action::decode(buf)?;
                    speaker.perform(action)?;
                },
    
                // receive ping
                Frame::Ping => {
                    sock.send(Frame::Pong).await?;
                },
    
                // close
                Frame::Close => break,
                _ => {},
            }
        }
    }

    Ok(())
}