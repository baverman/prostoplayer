keys       = require 'lodash/object/keys'
merge      = require 'lodash/object/merge'
difference = require 'lodash/array/difference'
is-empty   = require 'lodash/lang/isEmpty'

{fetch}    = require './zvooq.ls'
{parallel} = require './utils.ls'


str-ids = ->
    for id in it
        id.to-string!


module.exports = class Meta
    ->
        @releases = {}
        @tracks = {}
        @artist = {}
        @playlists = {}

    ensure: (it, done) !->
        tasks = {}
        if it.tracks
            tracks-ids = difference do
                str-ids it.tracks
                keys @tracks

            if tracks-ids.length
                tasks.tracks = fetch do
                    '/api/tiny/tracks'
                    ids: tracks-ids.join ','
                    include: 'release'
                    _

        if it.releases
            release-ids = difference do
                str-ids it.releases
                keys @releases

            if release-ids.length
                tasks.releases = fetch do
                    '/api/tiny/releases'
                    ids: release-ids.join ','
                    _

        if is-empty tasks
            return done(true)

        result <~ parallel tasks
        if result.tracks
            merge @tracks, result.tracks.tracks
            merge @releases, result.tracks.releases

        if result.releases
            merge @releases, result.releases.releases

        done(false)
