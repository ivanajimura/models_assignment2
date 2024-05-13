mtype = {red, green}

mtype sem1 = red, sem2 = red, sem3 = red;   // three semaphores
bool s0, s1, s2, s3;                        // four presence sensors
byte countZ0, countZ1, countZ2, countZ3;    // count the vehicles in each zone
byte n_cars = 0                                  // number of cars at the same time
byte max_cars = 255                           // max cars at the same time.

int max_total_cars = 300000                    // total cars until program is interrupted
int total_cars = 0                              // total cars until now


proctype Sensors() {

            do
                :: total_cars >= max_total_cars -> break;       //included to exit program eventually
                :: s0 = (countZ0 > 0);
                :: s1 = (countZ1 > 0);
                :: s2 = (countZ2 > 0);
                :: s3 = (countZ3 > 0);
            od;
}

proctype RoadsideUnit() {
    do
    :: total_cars >= max_total_cars -> break;               //included to exit program eventually
    :: !s0 && s1 -> atomic {    // intersection is empty and there is at least one car waiting in z1
        sem1 = green;
        sem2 = red;
        sem3 = red;
        printf("S1 is green now!\n");
        run printSems();
        }                   
    
    :: !s0 && s2 -> atomic {    // intersection is empty and there is at least one car waiting in z2
        sem1 = red;
        sem2 = green;
        sem3 = red;
        printf("S2 is green now!\n");
        run printSems();
        }                   

    :: !s0 && s3 -> atomic {    // intersection is empty and there is at least one car waiting in z3
        sem1 = red;
        sem2 = red;
        sem3 = green;
        printf("S3 is green now!\n");
        run printSems();
        }                   
    :: else -> skip             // if there is at least one car in the intersection, the car should leave the intersection freely
    od;
}

proctype Vehicles() {

    do
        :: total_cars >= max_total_cars -> break;       //included to exit program eventually

        :: countZ0 -> atomic {              // if there is a car in Z0, it can move
            countZ0--;
            n_cars--;
            printf("Car moved from Z0.\n");
            run printCars();
            }

        :: n_cars < max_cars -> atomic {        // while below limit, new cars can arrive
            if
                :: {countZ1++;
                    n_cars++;
                    total_cars++;
                    printf("New car in Z1.\n")
                    }
                :: {countZ2++;
                    n_cars++;
                    total_cars++;
                    printf("New car in Z2.\n")
                    }
                :: {countZ3++;
                    n_cars++;
                    total_cars++;
                    printf("New car in Z3.\n")
                    }
                :: skip
            fi;
            run printCars();
            }
        
        :: sem1 == green && countZ1 -> atomic {     // if there is a car in z1 and sem1==green, it goes to Z0
            //run printSems();
            countZ1--;
            countZ0++;
        }
        :: sem2 == green && countZ2 -> atomic {     // if there is a car in z2 and sem2==green, it goes to Z0
            //run printSems();
            countZ2--;
            countZ0++;
        }
        :: sem3 == green && countZ3 -> atomic {     // if there is a car in z3 and sem3==green, it goes to Z0
            //run printSems();
            countZ3--;
            countZ0++;
        }
    od;
}

proctype printSems(){
    printf("sem1: %e, sem2: %e, sem3: %e.\n", sem1, sem2, sem3)
}
proctype printCars(){
    printf("countZ0: %u, countZ1: %u, countZ2: %u, countZ3: %u, n_cars: %u, total_cars: %u.\n", countZ0, countZ1, countZ2, countZ3, n_cars, total_cars)
}

init {
    run Sensors();
    run RoadsideUnit();
    run Vehicles();
}