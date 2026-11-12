import { Request, Response, NextFunction } from 'express';
import {
  SleepReportUseCase,
  FeedingReportUseCase,
  DiapersReportUseCase,
  GrowthReportUseCase,
  MedicationReportUseCase,
  ChecklistUseCase,
} from './reports.usecase';

const sleepReport = new SleepReportUseCase();
const feedingReport = new FeedingReportUseCase();
const diapersReport = new DiapersReportUseCase();
const growthReport = new GrowthReportUseCase();
const medicationReport = new MedicationReportUseCase();
const checklist = new ChecklistUseCase();

export async function getSleepReport(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const { startDate, endDate } = req.query as { startDate?: string; endDate?: string };
    const result = await sleepReport.execute(babyId, req.userId!, { startDate, endDate });
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getFeedingReport(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const { startDate, endDate } = req.query as { startDate?: string; endDate?: string };
    const result = await feedingReport.execute(babyId, req.userId!, { startDate, endDate });
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getDiapersReport(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const { startDate, endDate } = req.query as { startDate?: string; endDate?: string };
    const result = await diapersReport.execute(babyId, req.userId!, { startDate, endDate });
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getGrowthReport(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const { startDate, endDate } = req.query as { startDate?: string; endDate?: string };
    const result = await growthReport.execute(babyId, req.userId!, { startDate, endDate });
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getMedicationReport(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const { startDate, endDate } = req.query as { startDate?: string; endDate?: string };
    const result = await medicationReport.execute(babyId, req.userId!, { startDate, endDate });
    res.json(result);
  } catch (error) {
    next(error);
  }
}

export async function getChecklist(req: Request, res: Response, next: NextFunction) {
  try {
    const { babyId } = req.params as { babyId: string };
    const { date } = req.query as { date?: string };
    const result = await checklist.execute(babyId, req.userId!, date);
    res.json(result);
  } catch (error) {
    next(error);
  }
}
