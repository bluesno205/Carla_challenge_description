""" 
Scenario Description 02.
The ego-vehicle is performing an unprotected left turn at an intersection,yielding to
oncoming traffic.This scenario occurs at both signalized and non-signalized junctions
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr')
param carla_map = 'Town05'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_MODEL = "vehicle.lincoln.mkz2017"

fourWayIntersection = filter(lambda i: i.is4Way and i.isSignalized, network.intersections)
intersec = Uniform(*fourWayIntersection)
ego_start_lane = Uniform(*intersec.incomingLanes)
ego_maneuvers = filter(lambda i: i.type == ManeuverType.LEFT_TURN, ego_start_lane.maneuvers)
ego_maneuver = Uniform(*ego_maneuvers)
ego_lanes = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]
ego_spawn_pt = OrientedPoint in ego_maneuver.startLane.centerline

adv_maneuvers = filter(lambda i: i.type == ManeuverType.STRAIGHT, ego_maneuver.conflictingManeuvers)
adv_maneuver = Uniform(*adv_maneuvers)
adv_lanes = [adv_maneuver.startLane, adv_maneuver.connectingLane, adv_maneuver.endLane]
adv_start_lane = adv_maneuver.startLane
npc_spawn_pt = OrientedPoint in adv_maneuver.startLane.centerline

ego = Car at ego_spawn_pt,
        with blueprint EGO_MODEL,
        with path ego_lanes,
        with constraint:
            follow_lane (duration = [1~20]):
                Speed(10)
                Position([30~40], behind = npc, at = 'start')
            brake (duration = [1~5]):
                Speed(10)

npc = Car at npc_spawn_pt,
            with path adv_lanes,
            with constraint:
                follow_lane (duration = [1~25]):
                    Speed(10)

npc1 = new Car ahead of npc by Range(15, 30),
            with path adv_lanes,
            with constraint:
                follow_lane (duration = [1~25]):
                    Speed(10)

npc2 = new Car ahead of npc1 by Range(5, 10),
            with path adv_lanes,
            with constraint:
                follow_lane (duration = [1~25]):
                    Speed(10)