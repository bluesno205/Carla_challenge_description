""" 
Scenario Description 19a.
While performing a maneuver, the ego-vehicle encounters a stopped vehicle in the road,
and must perform an emergency brake or an avoidance maneuver.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town07.xodr')
param carla_map = 'Town07'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_MODEL = "vehicle.lincoln.mkz2017"
EGO_SPEED = 10
SAFETY_DISTANCE = 20
BRAKE_INTENSITY = 1.0

behavior EgoBehavior(speed, trajectory):
    try:
        do FollowTrajectoryBehavior(target_speed=speed, trajectory=trajectory)
        do FollowLaneBehavior(target_speed=speed)
    interrupt when withinDistanceToAnyObjs(self, SAFETY_DISTANCE):
        take SetBrakeAction(BRAKE_INTENSITY)

fourWayIntersection = filter(lambda i: i.is2Way and i.isSignalized, network.intersections)

intersec = Uniform(*fourWayIntersection)
ego_start_lane = Uniform(*intersec.incomingLanes)

ego_maneuvers = filter(lambda i: i.type == ManeuverType.LEFT_TURN, ego_start_lane.maneuvers)
ego_maneuver = Uniform(*ego_maneuvers)
ego_trajectory = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]
ego_start_section = ego_maneuver.startLane.sections[-1]

ego_spawn_pt = OrientedPoint in ego_maneuver.startLane.centerline
npc_spawn_pt = OrientedPoint in ego_maneuver.endLane.centerline

ego = Car at ego_spawn_pt,
    with blueprint EGO_MODEL,
    with behavior EgoBehavior(EGO_SPEED, ego_trajectory)

npc = Car at npc_spawn_pt

require (ego_start_section.laneToLeft == adv_end_section)  # make sure the ego and adversary are spawned in opposite lanes
require 25 <= (distance to intersec) <= 30
require 15 <= (distance from adversary to intersec) <= 20
terminate when (distance to ego_spawn_pt) > 70