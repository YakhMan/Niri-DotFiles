if status is-interactive

end
function fish_greeting
    fastfetch --logo-animation-frame 0 --logo-width 22
end



if status is-interactive; and test "$XDG_VTNR" = 1
    if not set -q WAYLAND_DISPLAY
        exec niri-session
    end
end
