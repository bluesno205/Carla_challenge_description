""" 
Scenario Description 04.
The ego-vehicle needs to negotiate with other vehicles to cross an unsignalized
intersection. It is assumed that the first to enter the intersection has priority.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr') 
param carla_map = 'Town05'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_MODEL = "vehicle.lincoln.mkz2017"
EGO_SPEED = 10
SAFETY_DISTANCE = 20
BRAKE_INTENSITY = 1.0

behavior AdversaryBehavior(trajectory):
    do FollowTrajectoryBehavior(trajectory=trajectory)

behavior EgoBehavior(speed, trajectory):
    try:
        do FollowTrajectoryBehavior(target_speed=speed, trajectory=trajectory)
        do FollowLaneBehavior(target_speed=speed)
    interrupt when withinDistanceToAnyObjs(self, SAFETY_DISTANCE):
        take SetBrakeAction(BRAKE_INTENSITY)

fourWayIntersection = filter(lambda i: i.is4Way and not i.isSignalized, network.intersections)
intersec = Uniform(*fourWayIntersection)
ego_start_lane = Uniform(*intersec.incomingLanes)

ego_maneuver = Uniform(*ego_start_lane.maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

adv_maneuver = Uniform(*ego_maneuver.conflictingManeuvers)
adv_maneuver2 = filter(lambda l: not l==adv_maneuver1, Uniform(*ego_maneuver.conflictingManeuvers) )
adv_maneuver3 = filter(lambda l: not l==adv_maneuver1 and not l==adv_maneuver2, Uniform(*ego_maneuver.conflictingManeuvers) )
adv_trajectory1 = [adv_maneuver1.startLane, adv_maneuver1.connectingLane, adv_maneuver1.endLane]
adv_start_lane1 = adv_maneuver1.startLane
adv_trajectory2 = [adv_maneuver2.startLane, adv_maneuver2.connectingLane, adv_maneuver2.endLane]
adv_start_lane2 = adv_maneuver2.startLane
adv_trajectory3 = [adv_maneuver3.startLane, adv_maneuver3.connectingLane, adv_maneuver3.endLane]
adv_start_lane3 = adv_maneuver3.startLane

ego_spawn_pt = OrientedPoint in ego_maneuver.startLane.centerline
adv_spawn_pt1 = OrientedPoint in adv_maneuver1.startLane.centerline
adv_spawn_pt2 = OrientedPoint in adv_maneuver2.startLane.centerline
adv_spawn_pt3 = OrientedPoint in adv_maneuver3.startLane.centerline

ego = Car at ego_spawn_pt,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED, ego_trajectory)

adversary1 = Car at adv_spawn_pt1,
    with behavior AdversaryBehavior(adv_trajectory1)

adversary2 = Car at adv_spawn_pt2,
    with behavior AdversaryBehavior(adv_trajectory2)

adversary3 = Car at adv_spawn_pt3,
    with behavior AdversaryBehavior(adv_trajectory3)

require 20 <= (distance to intersec) <= 25
require 15 <= (distance from adversary to intersec) <= 20
terminate when (distance to ego_spawn_pt) > 70