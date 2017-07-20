# TODO Add functionality to search bar

mq = window.matchMedia( "(max-width: 768px)" )
$(document).ready ->
  if not mq.matches
    toIndex(0)
    autoComplete = []
    for contact in document.getElementById('contact-list').getElementsByClassName('contact')
      autoComplete.push(contact.getElementsByClassName('name')[0].innerHTML.replace(/&amp;/g, '&'))
  
    input = document.getElementById('office-search')
    awesomplete = new Awesomplete(input);
    awesomplete.list = autoComplete
    $("#office-search").bind 'keypress', (e) ->
      if e.which is 13
        setPage(searchDir(document.getElementById('office-search').value, autoComplete))
        document.getElementById('office-search').value = ''
      return
  else
    buildMobile()
  return

@buildMobile = () ->
  i = 0
  contacts = document.getElementById('contact-list').getElementsByClassName('contact')
  container = document.getElementsByClassName('mobile-dir')[0].getElementsByClassName('contact-container')[0]
  tempHTML = ''
  while i < contacts.length
    
    if i is 0
      tempHTML += '<h2 class="directory-heading" name="' + contacts[i].getElementsByClassName('name')[0].innerHTML[0].toLowerCase() +
          '">' + contacts[i].getElementsByClassName('name')[0].innerHTML + '</h2>'
    
    else if contacts[i].getElementsByClassName('name')[0].innerHTML[0].toLowerCase() isnt contacts[i - 1].getElementsByClassName('name')[0].innerHTML[0].toLowerCase()
      tempHTML += '<hr><h2 class="directory-heading" name="' + contacts[i].getElementsByClassName('name')[0].innerHTML[0].toLowerCase() +
          '">' + contacts[i].getElementsByClassName('name')[0].innerHTML + '</h2>'
    
    else
      tempHTML += '<h2 class="directory-heading">' + contacts[i].getElementsByClassName('name')[0].innerHTML + '</h2>'
    
    for detail in contacts[i].getElementsByClassName('detail')
      
      if detail.getElementsByClassName('heading').length
        tempHTML += '<p><strong>' + detail.getElementsByClassName('heading')[0].innerHTML + '</strong>'
      
      for line in detail.getElementsByClassName('line')
        tempHTML += '<br />' + line.innerHTML
      
      for link in detail.getElementsByTagName('a')
        tempHTML += '<br /><a title="' + link.title + '" class="' + link.className + '" href="' + link.href + '">' + link.innerHTML + '</a>'
        
      tempHTML += '</p>'
    tempHTML += '<br />'
    i++
    container.innerHTML = tempHTML
  return
  
@searchDir = (key, list) ->
  i = 0
  while i < list.length
    if key is list[i]
      return i
    i++
  return 0
  
@setPage = (pageIndex) ->
  $('#pages').removeClass('index') if $('#pages').hasClass('index')
  contactList = document.getElementById('contact-list')
  if (pageIndex >= contactList.length)
    pageIndex = (contactList.length - 1)
  contact = contactList.getElementsByClassName('contact')[pageIndex]
  pages = document.getElementById('pages')
  # The max number of lines on page 1 when there is one line in the header is 16
  maxLines = 16
  # We shall calculate the number of lines the header makes up, subtract 1 for the first line and multiply
  # it by two, this is the number of lines that the page looses for the extra header lines if there are any
  maxLines -= ((headerLines(contact.getElementsByClassName('name')[0].innerHTML) - 1) * 2)
  # now we have to determine what fields will fit on the first page
  details = contact.getElementsByClassName('detail')
  counter = 0
  lines = 0
  done = false
  
  #determine how many details will be on the first page by their line length
  while not done and counter isnt details.length
    pLength = (details[counter].getElementsByClassName('heading').length * 3) + details[counter].getElementsByClassName('line').length + details[counter].getElementsByClassName('link').length + (details[counter].getElementsByClassName('btn').length * 2)
    if (lines + pLength < maxLines)
      lines += pLength
      counter++
    else
      done = true
  
  i = 0
  document.getElementById('page-1').innerHTML = '<h1 data-index="' + pageIndex + '">' + contact.getElementsByClassName('name')[0].innerHTML + '</h1>'
  document.getElementById('page-2').innerHTML = ""
  
  # adding each detail to the first page that is supposed to be on it
  while i < counter
    document.getElementById('page-1').innerHTML += generateDetailHTML(details[i])
    i++
  
  # put remaining details in the second page
  while i < details.length
    document.getElementById('page-2').innerHTML += generateDetailHTML(details[i])
    i++
  
  # add navigation
  navHTML = '<div class="dir-nav">'
  if pageIndex isnt 0
    navHTML += '<a onclick="prev()" class="btn prev">❮ Prev</a>'
  navHTML += '<a onclick="toIndex(0)" class="btn index">Index</a></div>'
  document.getElementById('page-1').innerHTML += navHTML
  
  if pageIndex isnt (contactList.getElementsByClassName('contact').length - 1)
    document.getElementById('page-2').innerHTML += '<div class="dir-nav">' +
        '<a onclick="next()" class="btn next">Next ❯</a>' +
        '</div>'
  
  return

@next = () ->
  setPage(parseInt(document.getElementById('page-1').getElementsByTagName('h1')[0].getAttribute('data-index')) + 1)
  return

@prev = () ->
  setPage(parseInt(document.getElementById('page-1').getElementsByTagName('h1')[0].getAttribute('data-index')) - 1)
  return

@generateDetailHTML = (detail) ->
  detailHTML = '<p>'
  
  # Check for heading in detail
  if detail.getElementsByClassName('heading').length
    detailHTML += '<strong>' + detail.getElementsByClassName('heading')[0].innerHTML + '</strong><br/>'
  
  # Check for lines in detail
  if detail.getElementsByClassName('line').length
    j = 0
    while j < detail.getElementsByClassName('line').length
      detailHTML += detail.getElementsByClassName('line')[j].innerHTML
      if (j isnt detail.getElementsByClassName('line').length - 1)
        detailHTML += '<br/>'
      j++
  
  # Check for links in detail
  if detail.getElementsByClassName('link').length
    j = 0
    while j < detail.getElementsByClassName('link').length
      detailHTML += '<a href="' + detail.getElementsByClassName('link')[j].getAttribute('href') + '" title="' + detail.getElementsByClassName('link')[j].getAttribute('title') + '" class="link">'
      detailHTML += detail.getElementsByClassName('link')[j].innerHTML
      detailHTML += '</a>'
      if (j isnt detail.getElementsByClassName('link').length - 1)
        detailHTML += '<br/>'
      j++
  
  # Check for btns in detail
  if detail.getElementsByClassName('btn').length
    j = 0
    while j < detail.getElementsByClassName('btn').length
      detailHTML += '<a href="' + detail.getElementsByClassName('btn')[j].getAttribute('href') + '" title="' + detail.getElementsByClassName('btn')[j].getAttribute('title') + '" class="btn">'
      detailHTML += detail.getElementsByClassName('btn')[j].innerHTML
      detailHTML += '</a>'
      if (j isnt detail.getElementsByClassName('btn').length - 1)
        detailHTML += '<br/>'
      j++
  
  # close out detail
  detailHTML += '</p>'
  return detailHTML

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
      if (j - currentNewline) > (15 - 1) # minus 1 because we index at 0
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

# Copy of headerLines for the index page to determine if titles of departments breach the 23 char line limit
@indexLines = (header) ->
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
      if (j - currentNewline) > (30 - 1) # minus 1 because we index at 0
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
  
@toIndex = (index) ->
  $('#pages').addClass('index') if not $('#pages').hasClass('index')
  contactList = document.getElementById('contact-list')
  contacts = contactList.getElementsByClassName('contact')
  pages = document.getElementById('pages')
  p1Lines = 8
  p2Lines = 10
  
  counter = index
  lines = 0
  done = false
  
  while not done and counter isnt contacts.length
    pLength = indexLines(contacts[counter].getElementsByClassName('name')[0].innerHTML)
    if (lines + pLength <= p1Lines)
      lines += pLength
      counter++
    else
      done = true
  
  i = index
  
  if not index then document.getElementById('page-1').innerHTML = '<h1>Index</h1>'
  else document.getElementById('page-1').innerHTML = '<h1>Index Cont.</h1>'
  
  while i < counter
    document.getElementById('page-1').innerHTML += '<li><a alt="link to ' + contacts[i].getElementsByClassName('name')[0].innerHTML +
        'page" onclick="setPage(' + i + ')">' + contacts[i].getElementsByClassName('name')[0].innerHTML + '</a></li>'
    i++
  
  lines = 0
  done = false
  
  while not done and counter isnt contacts.length
    pLength = indexLines(contacts[counter].getElementsByClassName('name')[0].innerHTML)
    if (lines + pLength <= p2Lines)
      lines += pLength
      counter++
    else
      done = true
  
  document.getElementById('page-2').innerHTML = '<ul>'
  
  while i < counter
    document.getElementById('page-2').innerHTML += '<li><a alt="link to ' + contacts[i].getElementsByClassName('name')[0].innerHTML +
        'page" onclick="setPage(' + i + ')">' + contacts[i].getElementsByClassName('name')[0].innerHTML + '</a></li>'
    i++
  
  document.getElementById('page-2').innerHTML += '</ul>'
  
  # add navigation
  if index isnt 0
    document.getElementById('page-1').innerHTML += '<div class="dir-nav"><a onclick="toIndex(0)" class="btn prev">❮ First</a></div>'
  
  if counter isnt (contacts.length)
    document.getElementById('page-2').innerHTML += '<div class="dir-nav">' +
        '<a onclick="toIndex(' + counter + ')" class="btn next">Next ❯</a>' +
        '</div>'
  return