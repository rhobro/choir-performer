use choir::Speaker;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let mut s = Speaker::new("127.0.0.1".to_string());
    s.connect().await?;

    Ok(())
}