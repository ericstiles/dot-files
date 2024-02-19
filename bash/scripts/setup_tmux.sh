#!/usr/bin/env bash

SESSIONNAME="script"
tmux has-session -t $SESSIONNAME &> /dev/null

if [ $? != 0 ]; then
  # 0
    tmux new-session -s $SESSIONNAME -n script -d
    tmux send-keys -t $SESSIONNAME "bash" C-m
    tmux send-keys -t $SESSIONNAME "alias e='exit'" C-m
    tmux send-keys -t $SESSIONNAME "paw && dc up" C-m

  # 1
    tmux split-window -h
    tmux send-keys -t $SESSIONNAME "bash" C-m
    tmux send-keys -t $SESSIONNAME "alias e='exit'" C-m
    tmux send-keys -t $SESSIONNAME "paw && /gradlew bootRun --args='--spring.profiles.active=local' --stacktrace --debug-jvm" C-m

  # 2
    tmux split-window -v
    tmux send-keys -t $SESSIONNAME "bash" C-m
    tmux send-keys -t $SESSIONNAME "alias e='exit'" C-m
    tmux send-keys -t $SESSIONNAME "paw && cd ../payments-acceptance-terminal-emulator && npm run dev" C-m

  # 3
    tmux split-window -v
    tmux send-keys -t $SESSIONNAME "bash" C-m
    tmux send-keys -t $SESSIONNAME "alias e='exit'" C-m
    tmux send-keys -t $SESSIONNAME "paw" C-m

  # move back to middle pane and create additional smaller windows
    tmux select-pane -t 2
    tmux split-window -h
    tmux send-keys -t $SESSIONNAME "bash" C-m
    tmux send-keys -t $SESSIONNAME "alias e='exit'" C-m
    tmux send-keys -t $SESSIONNAME "cd ~/repo/kroger-new/instore-payments-asycnapi" C-m
    tmux send-keys -t $SESSIONNAME "asyncapi start studio -f in-store-payments-asyncapi.yml" C-m

    tmux split-window -h
    tmux send-keys -t $SESSIONNAME "bash" C-m
    tmux send-keys -t $SESSIONNAME "alias e='exit'" C-m
    tmux send-keys -t $SESSIONNAME "cd ~/repo/kroger-new/payment-hub-mock-server && npm run server" C-m

    tmux select-pane -t 3
fi

tmux attach -t $SESSIONNAME
