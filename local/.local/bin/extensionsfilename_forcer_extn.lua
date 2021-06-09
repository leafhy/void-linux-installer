-- File: "filename_forcer_extn.lua" 
--
-- VLC Extension 
--
--[[
Author - ogilvierothchild >> https://forum.videolan.org/viewtopic.php?f=29&t=136996#p502502
STEP 1/2:

    Copy this script file into VLC lua extensions folder.

    VLC folder path:

        Windows: *C:\Program Files\VideoLAN\VLC\lua\extensions*
        macOS: ~/Library/Application\ Support/org.videolan.vlc/lua/extensions/
        Linux user path: /home/root/.local/share/vlc/lua/extensions
        Linux system path: /usr/share/vlc/lua/extensions
    
    On Linux, do
    
        mkdir -p ~/.local/share/vlc/lua/extensions
    
    and copy this file there, or to /usr/share/vlc/lua/extensions
    
    See also: https://www.vlchelp.com/install-vlc-media-player-addon/


STEP 2/2:

    Restart VLC

    Activate the extension in VLC menu "View > Filename Forcer"
    or "VLC > Extensions > Filename Forcer" on Mac OS X.
    
    If you dont see it, run 
        vlc --verbose=2
    to verify the extension is being loaded
    --
    Modified from Filename_Forcer.lua by user mederi
    See: https://forum.videolan.org/viewtopic.php?f=29&t=136996
    Tested on VLC 3.0.8
    Changes:
      - removed useless dialog
      - removed recursive meta updates
      - added shortdesc so it shows in view menu
      - added support for smb://
      - removed test for leading '/' in file uri's
      - re-enabled call to update function
    
]]--

-- levels : 0:no msgs, 1:on change, 2:debug
local verbosity = 1

function descriptor()
    return {
        title = "Filename Forcer",
        version = "1.0",
        author = "maali",
        shortdesc = "Filename Forcer",
        capabilities = {"meta-listener", "input-listener"}
        -- capabilities = {}
    }
end

function activate()
    debug("activate")
end

function deactivate()
    debug("deactivate")
end

function input_changed()
    debug("input_changed")
end

function meta_changed()
    debug("meta_changed")
    filename_forcer()
    collectgarbage()
end

function close()
    debug("close")
    vlc.deactivate()
end

---------------------------

function filename_forcer()
    debug("checking")
    if vlc.input.item() then
        local curi = vlc.input.item():uri()
        debug("uri = '" .. curi .. "'")
        if curi and (string.sub(curi,1,7)=="file://" or string.sub(curi,1,6)=="smb://") then
            local filename = vlc.strings.decode_uri(string.gsub(tostring(curi), "^.*/(.-)$","%1"))
            debug("filename = '" .. filename .. "'")
            local s = vlc.input.item():metas()["title"]
            local original = s and s or ""
            debug("original = '" .. original .. "'")
            if original~=filename then
                vlc.input.item():set_meta("title", filename)
                report("*** update: set title to filename ***")
            end
        end
    end
end

---------------------------

function report(s)
    if verbosity > 0 then
        vlc.msg.info("filename_forcer: " .. s)
    end
end

function debug(s)
    if verbosity > 1 then
        vlc.msg.info("filename_forcer: " .. s)
    end
end
