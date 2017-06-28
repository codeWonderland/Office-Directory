$(document).ready ->
  return
  
@headerLines = (header) ->
  numSpaces = 0
  
  # We subtract 1 because we don't care if the last character is a space
  for char in header
    if char is ' '
      numSpaces++
      
  currentNewline = 0
  # the number of words is equal to the number of spaces between words(numSpaces) + 1
  numLines = 1
  # at most we will have a number of lines equal to the number of words
  i = 0
  while i < numSpaces
    newline = false
    # we want to index from the newline
    j = currentNewline
    spaceIndex = 0
    spacesPassed = 0
    
    # while we haven't hit a new line and we haven't reached the end of the header
    while not newline and j < header.length
      # if we hit a space and it isn't the last character in the header
      # we want to index this space's location and add 1 to the amount of spaces we have hit since the newline
      if header[j] is ' ' and j isnt (header.length - 1)
        spaceIndex = j
        spacesPassed++
        
      # if we reach the max line length we want to make the newline index equal to the index of the last 
      # space plus 1 (spaces won't take up room at the beginning of a line)
      if (j - currentNewline) > (14 - 1) # minus 1 because we index at 0
        currentNewline = spaceIndex + 1
        # we also want to add one to the number of lines so far
        # however if this character is a space and there is nothing after it we don't want to add a new line
        if header[j] isnt ' '
          numLines++
        else if j isnt (header.length - 1)
          numLines++
        # since we are only going to have a max number of lines equal the number of words
        # we are expecting one line per space + 1 and our for loop is based around this
        # if we passed more than 1 space then we want to increase i for the extra space(s)
        i += spacesPassed - 1
        # this would also mark a new line so we want to end the while loop
        newline = true
      # in the event we didn't pass the number of characters allowed, we increase the index and continue testing
      else
        j++
    i++
  
  return numLines