source /etc/fang_hacks.cfg

start()
{
  for p in $MOUNTS;do
    mkdir -p $p
  done
  mount -a
}

status()
{
  mount
}

case $1 in start|status)
  $1 "$@"
  ;;
esac
