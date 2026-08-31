class_name GameGroups
extends RefCounted

# Centralised scene-group names, so gameplay code refers to constants instead of scattered string
# literals (AGENTS: "Evitar strings magicos... Centralizar constantes"). Values match the spellings
# the main game already uses, so this is cross-compatible.

const PLAYER := "player"                 # the player character / hurtbox
const ENEMIES := "enemies"               # anything the player's attack can damage
const PLAYER_BODY := "player_body"       # the reclaimable headless body left on the map
const BODY_CLAIMANT := "body_claimant"   # reservation: one enemy heading for the body at a time
