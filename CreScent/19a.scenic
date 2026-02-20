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

fourWayIntersection = filter(lambda i: i.is2Way and i.isSignalized, network.intersections)
intersec = Uniform(*fourWayIntersection)
ego_start_lane = Uniform(*intersec.incomingLanes)
ego_maneuvers = filter(lambda i: i.type == ManeuverType.LEFT_TURN, ego_start_lane.maneuvers)
ego_maneuver = Uniform(*ego_maneuvers)
ego_spawn_pt = OrientedPoint in ego_maneuver.startLane.centerline
ego_lane_sec = filter(lambda i: i._laneToRight == ego_maneuver.endLane or i._laneToLeft == ego_maneuver.endLane, ego_start_lane.maneuvers)
ego_lanes = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

npc = Car on ego_maneuver.endLane,
        with constraint:
	    keep_position(duration = [1~25]):
		Position(0, at = 'all')

ego = Car at ego_spawn_pt,
        with blueprint EGO_MODEL,
        with path ego_lanes,
        with constraint:
            follow_lane (duration = [1~20]):
                Speed(10)
                Position([30~40], behind = npc, at = 'start')
            brake (duration = [1~5]):
                Speed(10)