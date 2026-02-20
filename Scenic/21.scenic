""" 
Scenario Description 21.
The ego-vehicle must exit a parallel parking bay into a flow of traffic.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_SPEED = 10
SLOW_CAR_SPEED = 6
BLOCKING_CAR_DIST = 20
DIST_THRESHOLD = 15

behavior CutBehavior(leftpath, origpath=[]):
	laneChangeCompleted = False
	try: 
		do FollowLaneBehavior(EGO_SPEED)
	interrupt when withinDistanceToAnyObjs(self, DIST_THRESHOLD) and not laneChangeCompleted:
		do LaneChangeBehavior(laneSectionToSwitch=leftpath, target_speed=10)
		laneChangeCompleted = True

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
parkPt = OrientedPoint following roadDirection from park_spot for -20
parkPt1 = OrientedPoint following roadDirection from park_spot for -20
spawnPt1 = OrientedPoint following roadDirection from spawnPt for 20
spawnPt2 = OrientedPoint following roadDirection from spawnPt for -20

ego = Car following roadDirection from park2 for BLOCKING_CAR_DIST,
	with behavior CutBehavior(EGO_SPEED)

park2 = Car at parkPt
park1 = Car at parkPt1

cutCar = Car at spawnPt,
	with behavior FollowLaneBehavior(leftLane, [initLaneSec])

cutCar1 = Car at spawnPt1,
	with behavior FollowLaneBehavior(leftLane, [initLaneSec])

cutCar2 = Car at spawnPt2,
	with behavior FollowLaneBehavior(leftLane, [initLaneSec])

require (distance from ego to intersection) > 10