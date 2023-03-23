require 'openai'
require 'ruby_speech'

# Initialize OpenAI API
Openai.api_key = "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"

# Initialize the text-to-speech engine
engine = RubySpeech::Engine.new

def transcribe_audio_to_text(filename)
  recognizer = SpeechRecognition::Client.new
  audio = RubySpeech::AudioStream.new(File.binread(filename))
  result = recognizer.recognize(audio)
  result.transcription
end

def generate_response(prompt)
  response = Openai::Completion.create(
    engine: "text-davinci-003",
    prompt: prompt,
    max_tokens: 4000,
    n: 1,
    stop: nil,
    temperature: 0.5
  )
  response.choices[0].text
end

def speak_text(text)
  ssml = RubySpeech::SSML.draw { speak text }
  audio = engine.speak(ssml)
  audio.play
end

def main()
  while true do
    # Wait for user to say "Genius"
    puts "Say 'Genius' to start recording your question"
    response = gets.chomp
    if response.downcase == 'genius'
      # Record audio
      filename = "input.wav"
      puts "Say your question"
      recording = SpeechRecognition::Client.record { silence_timeout: nil }
      File.binwrite(filename, recording.audio_content)

      # Transcribe audio to text
      text = transcribe_audio_to_text(filename)
      if text
        puts "You said: #{text}"

        # Generate the response
        prompt = "What is #{text}?"
        response = generate_response(prompt)
        puts "ChatGPT-3 says: #{response}"

        # Read response using text-to-speech
        speak_text(response)
      end
    end
  end
end

if __FILE__ == $0
  main()
end
