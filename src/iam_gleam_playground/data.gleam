import gleam/dynamic.{type DecodeErrors, type Dynamic}

pub type Data {
  Data(content: String)
}

pub fn decode(json: Dynamic) -> Result(Data, DecodeErrors) {
  let decoder = dynamic.decode1(Data, dynamic.field("content", dynamic.string))
  decoder(json)
}
