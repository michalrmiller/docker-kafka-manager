#!/bin/bash
SBT_OPTS="$SBT_OPTS -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"
java $SBT_OPTS -jar /sbt/sbt-launch.jar "$@"