use futures::*;
use prost::Message;
use tokio::sync::{mpsc::{self, UnboundedReceiver, UnboundedSender}};

use crate::{Transport, proto::*};

pub struct Speaker {
    ip: String,

    // comms with processes
    send: Option<UnboundedSender<Message>>,
    recv: Option<UnboundedReceiver<Message>>,
}

impl Speaker {
    pub fn new(ip: String) -> Self {
        Self {
            ip,

            send: None,
            recv: None,
        }
    }

    // TODO stream
    pub async fn connect(&mut self) -> anyhow::Result<()> {
        // check if required TODO

        // connect
        let conn = Transport::connect(self.ip.to_string(), 5050).await?; // todo string
        let (send, mut recv) = conn.split();

        // receiving task
        let (recv_write, recv_read) = mpsc::unbounded_channel();
        tokio::spawn(async move {
            while let Some(message) = recv.next().await {
                // decode
                let message = Message::decode(buf)?;
                // channel
                recv_write
            }
        });

        // sending task
        let (send_write, mut send_read) = mpsc::unbounded_channel();
        tokio::spawn(async move {
            while let Some(message) = send_read.recv().await {
            }
        });

        self.send = Some(send_write);
        self.recv = Some(recv_read);
        Ok(())
    }

    pub fn is_connected(&self) -> bool {
        self.send.is_some()
    }

    pub async fn ping(&mut self) -> anyhow::Result<()> {
        // self.conn().await.send(Frame::Ping).await?;
        // self.send.unwrap().send(Action)
        self.send.as_mut().unwrap().send(Message{
            message: Some(message::Message::Ping(Ping { placeholder: true })),
        })?;
        Ok(())
    }
}

