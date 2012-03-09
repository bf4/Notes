def levenshtein(value, other, ins=2, del=2, sub=1)
  # ins, del, sub are weighted costs
  return nil if value.nil?
  return nil if other.nil?
  dm = []        # distance matrix

  # Initialize first row values
  dm[0] = (0..value.length).collect { |i| i * ins }
  fill = [0] * (value.length - 1)

  # Initialize first column values
  for i in 1..other.length
    dm[i] = [i * del, fill.flatten]
  end

  # populate matrix
  for i in 1..other.length
    for j in 1..value.length
      # critical comparison
      dm[i][j] = [
           dm[i-1][j-1] +
             (value[j-1] == other[i-1] ? 0 : sub),
               dm[i][j-1] + ins,
           dm[i-1][j] + del
     ].min
    end
  end

  # The last value in matrix is the
  # Levenshtein distance between the strings
  dm[other.length][value.length]
end
  
target = "A Special Evening with Bill Plympton and Premiere Screening of Adventures in Plymptoons!"

possible_matches = [
"Projects 85: Dan Perjovschi",
"Young Architects Program",
"JoAnn Verburg",
"Barry Frydlender: Place and Time",
"Sensation and Sentiment: Early Cinema Posters",
"Focus: David Smith (1906-1965)",
"Re-picturing the Past/Picturing the Present",
"Automatic Update",
"Digitally Mastered: Recent Acquisitions from the Museum's Collection",
"Lines, Grids, Stains, and Words",
"Richard Serra Sculpture: Forty Years",
"Projects 85: Dan Perjovschi",
"Young Architects Program",
"JoAnn Verburg",
"Barry Frydlender: Place and Time",
"Sensation and Sentiment: Early Cinema Posters",
"Focus: David Smith (1906-1965)",
"Re-picturing the Past/Picturing the Present",
"Automatic Update",
"Digitally Mastered: Recent Acquisitions from the Museum's Collection",
"Lines, Grids, Stains, and Words ",
"Richard Serra Sculpture: Forty Years",
"Bill Plympton and Adventures in Plymptoons!"
  ]

def find_match(target,possible)
  possible.sort {|a,b| levenshtein(target,a,1,1,1) <=> levenshtein(target,b,1,1,1) }.first
end
puts  find_match(target,possible_matches).inspect

