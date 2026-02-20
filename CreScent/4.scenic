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

fourWayIntersection = filter(lambda i: i.is4Way and not i.isSignalized, network.intersections)
intersec = Uniform(*fourWayIntersection)
ego_start_lane = Uniform(*intersec.incomingLanes)
ego_maneuver = Uniform(*ego_start_lane.maneuvers)
ego_lanes = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

adv_maneuver1 = Uniform(*ego_maneuver.conflictingManeuvers)
adv_maneuver2 = filter(lambda l: not l==adv_maneuver1, Uniform(*ego_maneuver.conflictingManeuvers) )
adv_maneuver3 = filter(lambda l: not l==adv_maneuver1 and not l==adv_maneuver2, Uniform(*ego_maneuver.conflictingManeuvers) )
adv_lanes1 = [adv_maneuver1.startLane, adv_maneuver1.connectingLane, adv_maneuver1.endLane]
adv_lanes2= [adv_maneuver2.startLane, adv_maneuver2.connectingLane, adv_maneuver2.endLane]
adv_lanes3 = [adv_maneuver3.startLane, adv_maneuver3.connectingLane, adv_maneuver3.endLane]

ego_spawn_pt = OrientedPoint in ego_maneuver.startLane.centerline
adv_spawn_pt1 = OrientedPoint in adv_maneuver1.startLane.centerline
adv_spawn_pt2 = OrientedPoint in adv_maneuver2.startLane.centerline
adv_spawn_pt3 = OrientedPoint in adv_maneuver3.startLane.centerline

ego = Car at ego_spawn_pt,
        with path ego_lanes,
        with constraint:
            follow_lane (duration = [1~20]):
                Speed(10)
                Position(ego_lane.length, at = 'end')
            brake (duration = [1~5]):
                Speed(0, at = 'end')

adv1 = Car at adv_spawn_pt1,
        with path adv_lanes1,
        with constraint:
            follow_lane (duration = [1~25]):
                Speed(10)

adv2 = Car at adv_spawn_pt2,
        with path adv_lanes2,
        with constraint:
            follow_lane (duration = [1~25]):
                Speed(10)

adv3 = Car at adv_spawn_pt3,
        with path adv_lanes3,
        with constraint:
            follow_lane (duration = [1~25]):
                Speed(10)