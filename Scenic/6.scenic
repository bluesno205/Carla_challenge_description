""" 
Scenario Description 06.
The ego-vehicle needs to perform a turn at an intersection yielding to bicycles
crossing from either the left or right.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

monitor TrafficLights:
    freezeTrafficLights()
    while True:
        if withinDistanceToTrafficLight(ego, 100):
            setClosestTrafficLightStatus(ego, "green")
        if withinDistanceToTrafficLight(adversary, 100):
            setClosestTrafficLightStatus(adversary, "green")
        wait

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

fourWayIntersection = filter(lambda i: i.is4Way and i.isSignalized, network.intersections)

intersec = Uniform(*fourWayIntersection)
ego_start_lane = Uniform(*intersec.incomingLanes)

ego_maneuvers = filter(lambda i: i.type == ManeuverType.LEFT_TURN, ego_start_lane.maneuvers)
ego_maneuver = Uniform(*ego_maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]
ego_start_section = ego_maneuver.startLane.sections[-1]

adv_maneuvers = filter(lambda i: i.type == ManeuverType.STRAIGHT, ego_maneuver.conflictingManeuvers)
adv_maneuver = Uniform(*adv_maneuvers)
adv_trajectory = [adv_maneuver.startLane, adv_maneuver.connectingLane, adv_maneuver.endLane]

adv_start_lane = adv_maneuver.startLane
adv_end_section = adv_maneuver.endLane.sections[0]

ego_spawn_pt = OrientedPoint in ego_maneuver.startLane.centerline
adv_spawn_pt = OrientedPoint in adv_maneuver.startLane.centerline

ego = Car at ego_spawn_pt,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED, ego_trajectory)

adversary = Car at adv_spawn_pt,
    with blueprint bicycles
    with behavior AdversaryBehavior(adv_trajectory)

adversary1 = new Car ahead of adversary by Range(2, 5),
    with blueprint bicycles
    with behavior AdversaryBehavior(adv_trajectory)

adversary2 = new Car ahead of adversary1 by Range(2, 5),
    with blueprint bicycles
    with behavior AdversaryBehavior(adv_trajectory)

require (ego_start_section.laneToLeft == adv_end_section)  # make sure the ego and adversary are spawned in opposite lanes
require 25 <= (distance to intersec) <= 30
require 15 <= (distance from adversary to intersec) <= 20
terminate when (distance to ego_spawn_pt) > 70