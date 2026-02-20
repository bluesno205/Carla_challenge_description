"" 
Scenario Description 05.
The ego-vehicle is going straight at an intersection but a crossing vehicle runs a
red light, forcing the ego-vehicle to avoid the collision. This scenario occurs at
both signalized and non-signalized junctions.
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
ego_maneuvers = filter(lambda i: i.type == ManeuverType.STRAIGHT, ego_startLane.maneuvers)
ego_maneuver = random.choice(list(ego_maneuvers))
ego_lane = ego_maneuver.startLane.centerline
ego_path = [ego_maneuver.startLane, ego_maneuver.connectingLane, ego_maneuver.endLane]

adv_maneuvers = filter(lambda i: i.type == ManeuverType.STRAIGHT, ego_maneuver.conflictingManeuvers)
adv_maneuver = random.choice(list(adv_maneuvers))
adv_lane = adv_maneuver.startLane.centerline
adv_path = [adv_maneuver.startLane, adv_maneuver.connectingLane, adv_maneuver.endLane]

ego = Car on ego_lane,
        with path ego_path,
        with constraint:
            follow_lane (duration = [1~20]):
                Speed(10)
                Position(ego_lane.length, at = 'end')
            brake (duration = [1~5]):
                Speed(0, at = 'end')

adv = Car on adv_lane,
        with path adv_path,
        with constraint:
            follow_lane (duration = [1~25]):
                Speed(10)