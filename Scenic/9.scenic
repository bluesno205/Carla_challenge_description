""" 
Scenario Description 09.
The ego-vehicle encounters a vehicle cutting into its lane from a lane of static
traffic.The ego-vehicle must decelerate, brake or change lane to avoid a collision.
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

ego = Car at spawnPt,
	with behavior FollowLaneBehavior(EGO_SPEED)

park2 = Car at parkPt

cutCar = Car following roadDirection from park2 for BLOCKING_CAR_DIST,
	with behavior CutBehavior(leftLane, [initLaneSec])

park1 = Car following roadDirection from cutCar for BLOCKING_CAR_DIST2

require (distance from ego to intersection) > 10