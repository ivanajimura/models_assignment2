mtype = {red, green}

mtype sem1 = red, sem2 = red, sem3 = red; // three semaphores
bool s0, s1, s2, s3; // four presence sensors
byte countZ0, countZ1, countZ2, countZ3; // count the vehicles in each zone

proctype Sensors() {
    do
    :: s0 = (countZ0 > 0)
    :: s1 = (countZ1 > 0)
    :: s2 = (countZ2 > 0)
    :: s3 = (countZ3 > 0)
    od;
}

proctype RoadsideUnit() {
    do
    :: (s0 && (s1 || s2 || s3)) -> {
        sem1 = green;
        sem2 = red;
        sem3 = red;
    }
    :: (s1 && (s0 || s2 || s3)) -> {
        sem1 = red;
        sem2 = green;
        sem3 = red;
    }
    :: (s2 && (s0 || s1 || s3)) -> {
        sem1 = red;
        sem2 = red;
        sem3 = green;
    }
    :: (s0 && !s1 && !s2 && !s3) -> {
        sem1 = green;
        sem2 = red;
        sem3 = red;
    }
    :: (s1 && !s0 && !s2 && !s3) -> {
        sem1 = red;
        sem2 = green;
        sem3 = red;
    }
    :: (s2 && !s0 && !s1 && !s3) -> {
        sem1 = red;
        sem2 = red;
        sem3 = green;
    }
    :: else -> {
        sem1 = red;
        sem2 = red;
        sem3 = red;
    }
    od;
}

proctype Vehicles() {
    do
    :: (sem1 == green) -> countZ1++

    :: (sem2 == green) -> countZ2++

    :: (sem3 == green) -> countZ3++

    :: (countZ1 > 0 && sem1 == green) -> countZ1--
    
    :: (countZ2 > 0 && sem2 == green) -> countZ2--
    
    :: (countZ3 > 0 && sem3 == green) -> countZ3--
    
    :: (countZ0 > 0) -> countZ0--
    od;
}

init {
    run Sensors();
    run RoadsideUnit();
    run Vehicles();
}