#!/bin/bash

mv _site/.git templates
stack exec site rebuild
mv templates/.git _site
