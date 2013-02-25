class TuneTab

  @dmap:  #duration map
    "w": 4
    "h": 2
    "q": 1
    "8": 0.5
    "16": 0.25
    "32": 0.125
    "64": 0.0625
    "-": 0

  @durations:
    "w": 1
    "h": 2
    "q": 4
    "8": 8
    "16": 16
    "32": 32

  config:
    tabType: "tab"
    tempo: 120
    beat: 4
    unityStatus: "unloaded"
    midiJsStatus: "unloaded"

  ###
  Converts a midi file into our tab code (NOT FINISHED)
  @param  {MidiFile} file from Jasmid's MidiFile
  @return {string} The tab code
  ###
  getTabCodeFromMidiFile: (file) ->
    for track in file.tracks
      noteOnFound = false
      for midiEvent, i in track
        if midiEvent.subtype is "noteOn"
          noteOnFound = true
          break
      if not noteOnFound
        continue
      notes = []
      note = 
        keys: []
      for midiEvent, i in track
        ratio = midiEvent.deltaTime / file.header.ticksPerBeat
        duration = "-"
        for d, v of @dmap
          duration = d if Math.abs(v - ratio) < Math.abs(v - ratio)
        if i isnt 0 and duration isnt "-"
          note.duration = duration
          notes.push note
          note = 
            keys: []
        if midiEvent.subtype is "noteOn"
          note.keys.push MIDI.noteToKey[midiEvent.noteNumber]
    ""

  ###
  Transforms the VexTab code into the simpler format
  @param  {string} code The simpler code from MapleTunes
  @return {string} The transformed code
  ###
  transformCode: (code) ->
    code = code.replace(/\/\*.*?\*\/\n?/g, "")
    staves = code.trim().split(/\n{2,}/g)
    staves = _.map staves, (staff) ->
      lines = staff.split("\n")
      lines = _.map lines, (line) ->
        if _(line).startsWith ">"
          line = "text .2," + _(line).trim(">")
        else
          line = "notes " + line
      staff = _.reduce lines, (memo, line, index) ->
        if (_(line).startsWith "notes") and index isnt 0
          return (memo + " | \n" + line).trim()
        else
          return (memo + "\n" + line).trim()
      , ""

    staves = _.map staves, (staff, index) =>
      if @config.tabType is "tab"
        staff = "tabstave notation=true\n" + staff
      else if @config.tabType is "single"
        staff = "tabstave notation=true tablature=false\n" + staff
      else if @config.tabType is "grand"
        staff = "tabstave notation=true tablature=false" + (if index%2 is 1 then " clef=bass" else "") + "\n" + staff

    res = "options width=960 scale=0.75 space=10\n\n"
    res += staves.join("\n\n")
    #log res
    res

  getTrackFromStaves: (staves) ->
    track = 
      bpm: @config.tempo
      beat: @config.beat
    notes = staves.reduce (memo, staff) ->
      memo.concat staff.note_notes
    , []
    noteGroups = []
    for note in notes
      d = note.duration
      if d is "b" #TODO handle special bars in the future
        continue
      noteGroup = 
        duration: TuneTab.durations[d]
        type: if note.noteType is "n" then "note" else "rest"
        keys: []
      for key in note.keyProps
        noteGroup.keys.push
          pitch: key.int_value + 12
      noteGroups.push noteGroup
    track.noteGroups = noteGroups
    track


  ###
  Returns a midi file from staves
  @param  {array} staves From VexFlow
  @return {Midi.Track}
  ###
  getMidiTrackFromStaves: (staves) ->
    track = new Midi.Track
    notes = staves.reduce (memo, staff) ->
      memo.concat staff.note_notes
    , []
    @addNotesToTrack track, notes

  ###
  TODO note lengths, rests, volume manipulators
  @param {Midi.Track} track
  @param {note_notes[]} notes From VexFlow staves
  ###
  addNotesToTrack: (track, notes) ->
    channel = 0
    ###
    track.noteOn(0, 'c4', 400, 0)
    track.noteOn(0, 'e4', 0, 0)
    track.noteOff(0, 'c4', 1, 0)
    track.noteOff(0, 'e4', 0, 0)
    ###
    skipAmount = 128
    for note in notes
      d = note.duration
      if d is "b" #TODO handle special bars in the future
        continue
      ticks = 128
      if _.has TuneTab.dmap, d
        ticks = 128 * TuneTab.dmap[d]
      if note.noteType isnt "n"
        skipAmount += ticks
        continue
      first = true
      for key in note.keyProps
        track.noteOn channel, key.int_value + 12, (if first then skipAmount + 2 else 0)
        skipAmount = 0
        first = false
      first = true
      for key in note.keyProps
        track.noteOff channel, key.int_value + 12, (if first then ticks - 2 else 0)
        first = false
    track
