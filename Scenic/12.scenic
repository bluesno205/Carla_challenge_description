""" 
Scenario Description 12.
The ego-vehicle encounters an obstacle blocking the lane and must perform a lane
change into traffic moving in the same direction to avoid it. The obstacle may be
a construction site, an accident or a parked vehicle.
"""

param map = localPath('../../tests/formats/opendrive/maps/CARLA/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model

# param map = localPath('../../tests/formats/opendrive/maps/LGSVL/SanFrancisco.xodr')
# param lgsvl_map = 'SanFrancisco'
# model scenic.simulators.lgsvl.model

EGO_SPEED = 10
SLOW_CAR_SPEED = 6
EGO_TO_CAR = 10
DIST_THRESHOLD = 15

behavior EgoBehavior(leftpath, origpath=[]):
	laneChangeCompleted = False
	try: 
		do FollowLaneBehavior(EGO_SPEED)
	interrupt when withinDistanceToAnyObjs(self, DIST_THRESHOLD) and not laneChangeCompleted:
		do LaneChangeBehavior(laneSectionToSwitch=leftpath, target_speed=10)
		laneChangeCompleted = True

behavior SlowCarBehavior():
	do FollowLaneBehavior(SLOW_CAR_SPEED)

laneSecsWithRightLane = []
for lane in network.lanes:
	for laneSec in lane.sections:
		if laneSec._laneToRight != None:
			laneSecsWithRightLane.append(laneSec)

assert len(laneSecsWithRightLane) > 0, \
	'No lane sections with adjacent left lane in network.'

initLaneSec = Uniform(*laneSecsWithRightLane)
rightLane = initLaneSec._laneToRight

spawnPt = OrientedPoint on rightLane.centerline
carPt = OrientedPoint on initLaneSec.centerline
carPt1 = OrientedPoint following roadDirection from carPt for EGO_TO_CAR
carPt2 = OrientedPoint following roadDirection from carPt1 for EGO_TO_CAR

ego = Car at spawnPt,
	with behavior EgoBehavior(rightLane, [initLaneSec])

cyclist = Car following roadDirection from ego for EGO_TO_CAR,
	with behavior SlowCarBehavior()

vehicle = Car at carPt,
	with behavior FollowLaneBehavior(EGO_SPEED)

vehicle1 = Car at carPt1,
	with behavior FollowLaneBehavior(EGO_SPEED)

vehicle2 = Car at carPt2,
	with behavior FollowLaneBehavior(EGO_SPEED)

require (distance from ego to intersection) > 10
require (distance from cyclist to intersection) > 10