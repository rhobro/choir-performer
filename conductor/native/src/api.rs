pub struct Speaker {
    ip: String,
}

impl Speaker {
    pub fn new(ip: String) -> Speaker {
        return Self {
            ip,
        }
    }
}