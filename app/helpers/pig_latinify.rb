LETTERS = ("a".."z").to_a
NUMBERS = ("0".."9").to_a
VOWELS = ["a", "e", "i", "o", "u"]
PUNCTUATION = [".", ",", "?", "!", "'", "-", "_", ";", ":", "%", "[", "]", "(", ")", "{", "}", "<", ">",]
PAIRS = {
  "[" => "]",
  "(" => ")",
  "{" => "}",
  "<" => ">",
}

def pig_latinify(sentence)
  words = sentence.split(" ")
  translation = []

  words.each do |word|
    check = translate_word(word)
    translation << check
  end

  return translation.join(" ")
end

def translate_word(word)
  # HACK: targeting words wrapped in punctuation such as: "", (), []
  if (!LETTERS.include?(word[0]) && PUNCTUATION.include?(word[0]) && PAIRS[word[0]] === word[-1])
    str = word.downcase.gsub(/[^a-z0-9]/, '')
    new_word = translate_word_helper(str)
    return "#{word[0]}#{new_word}#{word[-1]}"
  else
    includes_punctuation = false
    char = ""
    if punctuation?(word[-1])
      includes_punctuation = true
      char = word[-1]
      word.slice!(-1) # remove punctuation for now
      if (word[0] === char)
        word
      end
    end
    new_word = translate_word_helper(word)
    return includes_punctuation ? new_word.concat(char) : new_word
  end
end

def translate_word_helper(word)
  # to avoid translating characters, such as & - : , drop all spaces and chars here
  # if the str is of length 0, just return
  str = word.downcase.gsub(/[^a-z ]/, '')
  if (str.length === 0)
    return word
  end

  # HACK: if the word ends with a number we are going to assume
  # this is a number or range, so just return as is
  if (NUMBERS.include?(word[-1]))
    return word
  elsif vowel?(word[0]) # if starts with vowel
    new_word = "#{word}yay"
  else
    split_index = first_vowel_index(word)
    start = word[split_index..-1]
    rest = word[0..split_index-1]
    new_word = "#{start}#{rest}ay".downcase
    if capitalized?(word)
      new_word.capitalize!
    end
  end
  return new_word
end

def first_vowel_index(word)
  i = 0
  word.split("").each do |letter|
    if vowel?(letter)
      break
    else
      i += 1
    end
  end
  return i
end

def vowel?(letter)
  VOWELS.include?(letter.downcase)
end

def punctuation?(char)
  PUNCTUATION.include?(char)
end

def capitalized?(word)
  if punctuation?(word[0])
    return false
  end
  word[0] === word[0].upcase
end
