""" 
Scenario Description 18.
The ego-vehicle encounters an pedestrian emerging from behind a parked vehicle
and advancing into the lane. The ego-vehicle must brake or maneuver to avoid it.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_SPEED = 10
SLOW_CAR_SPEED = 6
BLOCKING_CAR_DIST = 10
BLOCKING_CAR_DIST2 = 20
DIST_THRESHOLD = 15

behavior CutBehavior(leftpath, origpath=[]):
	laneChangeCompleted = False
	try: 
		do FollowLaneBehavior(EGO_SPEED)
	interrupt when withinDistanceToAnyObjs(self, DIST_THRESHOLD) and not laneChangeCompleted:
		do LaneChangeBehavior(laneSectionToSwitch=leftpath, target_speed=10)
		laneChangeCompleted = True

behavior PedestrianBehavior(min_speed=1, threshold=10):
    do CrossingBehavior(ego, min_speed, threshold)

laneSecsWithRightLane = [], laneSecs = []
for lane in network.lanes:
	for laneSec in lane.sections:
		if laneSec._laneToRight != None:
			laneSecs.append(laneSec._LaneToRight)
			laneSecsWithRightLane.append(laneSec)

assert len(laneSecsWithRightLane) > 0, \
	'No lane sections with adjacent left lane in network.'

initLaneSec = Uniform(*laneSecsWithRightLane)
rightLane = Uniform(*laneSecs)
leftLane = initLaneSec._laneToLeft

spawnPt = OrientedPoint on initLaneSec.centerline
park_spot = OrientedPoint on rightLane.centerline
parkPt_0 = OrientedPoint following roadDirection from park_spot for 20
parkPt = OrientedPoint following roadDirection from park_spot for -5
parkPt1 = OrientedPoint following roadDirection from parkPt for -20

ego = Car at spawnPt,
	with behavior FollowLaneBehavior(EGO_SPEED)

pedestrian = Pedestrian at park_spot,
	with behavior PedestrianBehavior(PEDESTRIAN_MIN_SPEED, THRESHOLD)

park1 = Car at parkPt_0

park2 = Car at parkPt

park3 = Car at parkPt1

require (distance from ego to intersection) > 10