""" 
Scenario Description 03.
The ego-vehicle is performing a right turn at an intersection, yielding to crossing
traffic. This scenario occurs at both signalized and non-signalized junctions
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town05.xodr') 
param carla_map = 'Town05'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

fourWayIntersection = filter(lambda i: i.is4Way and i.isSignalized, network.intersections)
intersec = random.choice(list(fourWayIntersection))
ego_startLane = random.choice(intersec.incomingLanes)

conflicting_rightTurn_maneuvers = filter(lambda i: i.type == ManeuverType.RIGHT_TURN, straight_maneuver.conflictingManeuvers)
ego_rightTurn_maneuver = Uniform(*conflicting_rightTurn_maneuvers)
ego_startLane = ego_rightTurn_maneuver.startLane
ego_lanes = [ego_rightTurn_maneuver.startLane, ego_rightTurn_maneuver.connectingLane, ego_rightTurn_maneuver.endLane]

startLane = Uniform(*intersec.incomingLanes)
straight_maneuvers = filter(lambda i: i.type == ManeuverType.STRAIGHT, startLane.maneuvers)
straight_maneuver = Uniform(*straight_maneuvers)
straight_trajectory = [straight_maneuver.startLane, straight_maneuver.connectingLane, straight_maneuver.endLane]

spwPt = startLane.centerline[-1]
csm_spwPt = ego_startLane.centerline[-1]

ego = Car following roadDirection from csm_spwPt for Uniform(15, 20) * -1,
        with blueprint EGO_MODEL,
        with path ego_lanes,
        with constraint:
            follow_lane (duration = [1~20]):
                Speed(10)
                Position([30~40], behind = npc, at = 'start')
            brake (duration = [1~5]):
                Speed(10)

npc = Car following roadDirection from spwPt for Uniform(10, 15) * -1,
            with path npc_path,
            with constraint:
                follow_lane (duration = [1~25]):
                    Speed(10)

npc1 = new Car ahead of npc by Range(15,20),
            with path npc_path,
            with constraint:
                follow_lane (duration = [1~25]):
                    Speed(10)

npc2 = new Car ahead of npc1 by Range(15,20),
            with path npc_path,
            with constraint:
                follow_lane (duration = [1~25]):
                    Speed(10)