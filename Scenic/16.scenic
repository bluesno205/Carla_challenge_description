""" 
Scenario Description 16.
The leading vehicle decelerates suddenly due to an obstacle and the ego-vehicle
must perform an emergency brake or an avoidance maneuver.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_MODEL = "vehicle.lincoln.mkz2017"
EGO_SPEED = 10
EGO_BRAKING_THRESHOLD = 12

LEAD_CAR_SPEED = 10
LEADCAR_BRAKING_THRESHOLD = 10

BRAKE_ACTION = 1.0

behavior EgoBehavior(speed=10):
    try:
        do FollowLaneBehavior(speed)
    interrupt when withinDistanceToAnyCars(self, EGO_BRAKING_THRESHOLD):
        take SetBrakeAction(BRAKE_ACTION)

behavior LeadingCarBehavior(speed=10):
    try: 
        do FollowLaneBehavior(speed)
    interrupt when withinDistanceToAnyObjs(self, LEADCAR_BRAKING_THRESHOLD):
        take SetBrakeAction(BRAKE_ACTION)

lane = Uniform(*network.lanes)

obstacle = Trash on lane.centerline

leadCar = Car following roadDirection from obstacle for Range(-50, -30),
        with behavior LeadingCarBehavior(LEAD_CAR_SPEED)

ego = Car following roadDirection from leadCar for Range(-15, -10),
        with blueprint EGO_MODEL,
        with behavior EgoBehavior(EGO_SPEED)

require (distance to intersection) > 80
terminate when ego.speed < 0.1 and (distance to obstacle) < 30