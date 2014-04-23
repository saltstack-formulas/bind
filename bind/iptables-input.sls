bind.input:
  iptables.chain_present:
    -

tcp:
  iptables.insert:
    - table: filter
    - position: -1
    - chain: bind.input
    - jump: ACCEPT
    - match: state
    - connstate: NEW,ESTABLISHED
    - dport: 53
    - proto: tcp
    - save: True

udp:
  iptables.insert:
    - position: -1
    - table: filter
    - chain: bind.input
    - jump: ACCEPT
    - match: state
    - connstate: NEW,ESTABLISHED
    - dport: 53
    - proto: udp
    - save: True

filter:
  iptables.insert:
    - position: -1
    - table: filter
    - chain: INPUT
    - jump: bind.input
    - save: True

