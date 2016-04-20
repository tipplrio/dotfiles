# Set colorful PS1 only on colorful terminals.
# gdircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.
use_color=false
if type -P gdircolors >/dev/null ; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  LS_COLORS=
  if [[ -f ~/.dir_colors ]] ; then
    # If you have a custom file, chances are high that it's not the default.
    used_default_dircolors="no"
    eval "$(gdircolors -b ~/.dir_colors)"
  elif [[ -f `brew --prefix`/etc/DIR_COLORS ]] ; then
    # People might have customized the system database.
    used_default_dircolors="maybe"
    eval "$(gdircolors -b `brew --prefix`/etc/DIR_COLORS)"
  else
    used_default_dircolors="yes"
    eval "$(gdircolors -b)"
  fi
  if [[ -n ${LS_COLORS:+set} ]] ; then
    use_color=true

    # The majority of systems out there do not customize these files, so we
    # want to avoid always exporting the large $LS_COLORS variable.  This
    # keeps the active env smaller, and it means we don't have to deal with
    # running new/old (incompatible) versions of `ls` compared to when we
    # last sourced this file.
    case ${used_default_dircolors} in
      no) ;;
      yes) unset LS_COLORS ;;
      *)
        ls_colors=$(eval "$(gdircolors -b)"; echo "${LS_COLORS}")
        if [[ ${ls_colors} == "${LS_COLORS}" ]] ; then
          unset LS_COLORS
        fi
        ;;
    esac
  fi
  unset used_default_dircolors
else
  # Some systems (e.g. BSD & embedded) don't typically come with
  # dircolors so we need to hardcode some terminals in here.
  case ${TERM} in
    [aEkx]term*|rxvt*|gnome*|konsole*|screen|cons25|*color) use_color=true;;
  esac
fi

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi

    if [[ ${EUID} == 0 ]] ; then
        PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    fi
else
    if [[ ${EUID} == 0 ]] ; then
        # show root@ when we don't have colors
        PS1='\u@\h \W \$ '
    else
        PS1='\u@\h \w \$ '
    fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color
